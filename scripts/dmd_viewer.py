"""
IO Moon Pinball DMD Viewer
--------------------------
Viewer for DMD (Dot Matrix Display) graphics from Sleic IO Moon pinball ROM.

ROM Structure:
- Animated Frames: ~400 frames, each 1030 bytes (6-byte header + 1024 bytes data)
  - Frame format: 128x32 pixels, 2 bitplanes (4 shades)
  - Header: 0x20 0x00 0x10 0x00 0x00 0x02 (height, 0, width_bytes, 0, 0, planes)
- Static Screens: 512 bytes, 1 bitplane (text/graphics without header)
  - Found throughout ROM1 area (0x80000+)
  - Includes: TILT, COIN, scores, game messages, designer credits
- Font data: Character mapping at 0x809B0, glyphs in various locations
"""

import argparse
import sys
from pathlib import Path

# Try to use an interactive backend for animations
import matplotlib
# Try interactive backends in order of preference
for backend in ['TkAgg', 'Qt5Agg', 'Qt4Agg', 'GTK3Agg', 'WXAgg', 'macosx']:
    try:
        matplotlib.use(backend, force=False)
        break
    except Exception:
        continue

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.animation import FuncAnimation
import numpy as np


# DMD Frame constants
FRAME_HEADER = bytes([0x20, 0x00, 0x10, 0x00, 0x00, 0x02])
FRAME_HEADER_SIZE = 6
FRAME_DATA_SIZE = 1024  # 2 planes * 512 bytes each
FRAME_TOTAL_SIZE = FRAME_HEADER_SIZE + FRAME_DATA_SIZE  # 1030 bytes
STATIC_SCREEN_SIZE = 512  # 1 plane, 1 bit per pixel
DMD_WIDTH = 128
DMD_HEIGHT = 32
BYTES_PER_ROW = 16  # 128 pixels / 8 bits

# ROM structure
ROM1_OFFSET = 0x80000  # ROM1 starts at this offset in combined ROM

# DMD dot matrix display effect (simulates physical pixel spacing)
# Each DMD pixel is rendered as a (dot_size × dot_size) colored block
# with a dark gap between dots, just like a real pinball DMD.
DMD_DOT_SCALE = 4   # Upscale factor: each pixel becomes scale×scale output pixels
DMD_DOT_GAP = 1     # Number of black border pixels between dots

# Typical DMD orange color (like classic pinball machines)
DMD_ORANGE = '#FF6600'
DMD_COLORS = [
    '#000000',  # Off (black)
    '#552200',  # Dim (dark orange)
    '#AA4400',  # Medium (medium orange)
    '#FF6600',  # Bright (full orange)
]

# Known interesting static screen offsets in combined ROM (ROM1 starts at 0x80000)
# Format: (offset, ROM1_offset, description)
KNOWN_STATIC_SCREENS = [
    # Designer credits
    (0xAA201, 0x2A201, "SOFTWARE - Luis J. Gosalbez, Toni Hernandez"),
    (0xAACF0, 0x2ACF0, "HARDWARE - Santos Aranda, Luis J. Gosalbez"),
    (0xAA300, 0x2A300, "ELECTROMECANICA - Toni Hernandez, J. Manuel Vazquez"),
    
    # Game messages (Spanish)
    (0xBB409, 0x3B409, "Dianas para luz Bola Extra"),
    (0xB5970, 0x35970, "BONOS DIANA"),
    (0xB5980, 0x35980, "BONOS DIANA (alt)"),
    (0x93890, 0x13890, "BONUS"),
    (0xB10F0, 0x310F0, "Extra Bola Extra"),
    (0x83DA0, 0x03DA0, "DROP TARGET"),
    (0x9DBA0, 0x1DBA0, "MILLIONS 5"),
    (0xA2E20, 0x22E20, "RECORD"),
    (0x97A10, 0x17A10, "TOTAL SCORE"),
    (0x82EB0, 0x02EB0, "IMPACT COUNT"),
    (0x83280, 0x03280, "ORBIT FLIP"),
    (0x83EB0, 0x03EB0, "STAR RIDE"),
    (0x99130, 0x19130, "SHOOT RAMPS"),
    (0x99930, 0x19930, "SHOOT HOLES"),
    (0x99A10, 0x19A10, "HOLES SHOOT"),
    (0x99200, 0x19200, "RAMPS SHOOT"),
    (0xBA3C0, 0x3A3C0, "BOLA RETENIDA MULTIBALL"),
    (0x91040, 0x11040, "all Extra Ball"),
    (0x90E60, 0x10E60, "SPECIAL PROBE OP"),
    (0x9D350, 0x1D350, "2 MILLION"),
    (0xBD420, 0x3D420, "3 MILLONES"),
    (0x85920, 0x05920, "JACKPOT"),
    (0x84880, 0x04880, "SUPERJACKPOT"),
    (0xBC000, 0x3C000, "Los Mejores"),
    (0x9D0C0, 0x1D0C0, "Best Players"),
    (0xBCFC0, 0x3CFC0, "MILLONES"),
    (0xB1910, 0x31910, "Partidas"),
    (0xBA0A0, 0x3A0A0, "MULTIBALL PARA MUL"),
    (0xBB000, 0x3B000, "TIRAR A"),
    (0xB9FF0, 0x39FF0, "RAMPAS"),
    (0x9AC00, 0x1AC00, "ORBITS OK"),
    (0xBBE00, 0x3BE00, "Nombres Jugadores"),
    
    # System messages
    # Note: TILT screen location not yet confirmed - may be stored differently
]


def find_frames(rom_data: bytes) -> list:
    """Find all DMD frames in the ROM by searching for the header pattern."""
    frames = []
    offset = 0
    graphics_end = 0x80000  # Graphics area ends around here
    
    while offset < min(len(rom_data), graphics_end):
        pos = rom_data.find(FRAME_HEADER, offset)
        if pos == -1 or pos >= graphics_end:
            break
        frames.append({
            'index': len(frames),
            'offset': pos,
            'header_offset': pos,
            'data_offset': pos + FRAME_HEADER_SIZE,
            'type': 'animated',
        })
        offset = pos + 1
    
    return frames


def find_static_screens(rom_data: bytes) -> list:
    """
    Find static DMD screens in ROM using header-based detection.
    
    Each screen block has the structure:
    - Header (6 bytes): 20 00 10 00 00 02 (height=32, row_bytes=16, size=512)
    - Bitmap 1 (512 bytes): English version
    - Bitmap 2 (512 bytes): Spanish version
    
    Note: The area 0xA9D00-0xAC000 contains scrolling credits animation data,
    NOT static screens. Use find_scrolling_credits() to extract that data.
    """
    screens = []
    
    SCREEN_HEADER = bytes([0x20, 0x00, 0x10, 0x00, 0x00, 0x02])
    SEARCH_START = 0x82000
    SEARCH_END = min(len(rom_data), 0xC0000)
    
    pos = SEARCH_START
    block_index = 0
    
    while pos < SEARCH_END - 6:
        pos = rom_data.find(SCREEN_HEADER, pos)
        if pos == -1 or pos >= SEARCH_END:
            break
        
        header_offset = pos
        bitmap1_offset = pos + 6
        bitmap2_offset = pos + 6 + 512
        
        if bitmap2_offset + 512 > len(rom_data):
            pos += 1
            continue
        
        bitmap1_data = rom_data[bitmap1_offset:bitmap1_offset+512]
        lit_pixels1 = sum(bin(b).count('1') for b in bitmap1_data)
        
        bitmap2_data = rom_data[bitmap2_offset:bitmap2_offset+512]
        lit_pixels2 = sum(bin(b).count('1') for b in bitmap2_data)
        
        # Filter empty or noisy screens
        if lit_pixels1 < 50 and lit_pixels2 < 50:
            pos += 1
            continue
        
        if lit_pixels1 > 3500 or lit_pixels2 > 3500:
            pos += 1
            continue
        
        # Add English bitmap
        screens.append({
            'index': len(screens),
            'block_index': block_index,
            'offset': bitmap1_offset,
            'header_offset': header_offset,
            'data_offset': bitmap1_offset,
            'type': 'static',
            'language': 'EN',
            'lit_pixels': lit_pixels1,
            'pair_offset': bitmap2_offset,
        })
        
        # Add Spanish bitmap if it has content
        if lit_pixels2 >= 50:
            screens.append({
                'index': len(screens),
                'block_index': block_index,
                'offset': bitmap2_offset,
                'header_offset': header_offset,
                'data_offset': bitmap2_offset,
                'type': 'static',
                'language': 'ES',
                'lit_pixels': lit_pixels2,
                'pair_offset': bitmap1_offset,
            })
        
        block_index += 1
        pos += 1030
    
    return screens


def find_scrolling_credits(rom_data: bytes) -> list:
    """
    Extract scrolling credits animation data from the ROM.
    
    The credits are stored as a continuous vertical strip at 0xA9D00-0xAC000.
    This function extracts individual text elements based on content boundaries.
    
    Returns a list of credit screens, each containing:
    - offset: Start offset in ROM
    - height: Number of rows
    - data: The row data
    - text_hint: Approximate text content (for identification)
    """
    CREDITS_START = 0xA9D00
    CREDITS_END = 0xAC000
    
    if len(rom_data) < CREDITS_END:
        return []
    
    total_rows = (CREDITS_END - CREDITS_START) // 16
    
    # Calculate content per row
    row_content = []
    for i in range(total_rows):
        offset = CREDITS_START + i * 16
        row_data = rom_data[offset:offset+16]
        bits = sum(bin(b).count('1') for b in row_data)
        row_content.append(bits)
    
    # Find contiguous blocks of content (text screens)
    credits = []
    in_screen = False
    screen_start = 0
    
    for i, content in enumerate(row_content):
        if content > 5 and not in_screen:
            # Start of a new screen
            in_screen = True
            screen_start = max(0, i - 1)  # Include 1 row padding
        elif content <= 5 and in_screen:
            # End of screen
            screen_end = min(i + 1, total_rows)  # Include 1 row padding
            if screen_end - screen_start >= 5:  # Minimum height
                credits.append({
                    'index': len(credits),
                    'offset': CREDITS_START + screen_start * 16,
                    'height': screen_end - screen_start,
                    'type': 'credits',
                })
            in_screen = False
    
    # Handle screen at end
    if in_screen:
        credits.append({
            'index': len(credits),
            'offset': CREDITS_START + screen_start * 16,
            'height': total_rows - screen_start,
            'type': 'credits',
        })
    
    return credits


def decode_credits_frame(rom_data: bytes, credit_info: dict) -> np.ndarray:
    """
    Decode a scrolling credits frame into a 2D numpy array.
    
    Unlike static screens (32 rows), credits frames can have variable height.
    The output is padded/cropped to 32 rows for consistent display.
    """
    offset = credit_info['offset']
    height = min(credit_info['height'], 64)  # Max 64 rows
    
    # Extract rows
    rows = []
    for row in range(height):
        row_offset = offset + row * 16
        row_data = rom_data[row_offset:row_offset+16]
        row_bits = []
        for b in row_data:
            for bit in range(8):
                row_bits.append(3 if b & (0x80 >> bit) else 0)
        rows.append(row_bits)
    
    img = np.array(rows, dtype=np.uint8)
    
    # Pad to 32 rows if needed, or crop if too tall
    if img.shape[0] < 32:
        padding = np.zeros((32 - img.shape[0], 128), dtype=np.uint8)
        img = np.vstack([img, padding])
    elif img.shape[0] > 32:
        img = img[:32]
    
    return img


def decode_frame(rom_data: bytes, frame_info: dict, invert: bool = True) -> np.ndarray:
    """
    Decode an animated DMD frame into a 2D numpy array with values 0-3.
    
    Frame format:
    - 1024 bytes total: 512 bytes plane 0 + 512 bytes plane 1
    - Each plane: 32 rows x 16 bytes = 512 bytes

    NOTE: this renderer's conventions differ from the hardware's, and both
    differences are cosmetic (they swap brightness levels 1 and 2):
    - the panel treats a SET bit as lit; `invert` defaults to True here, so
      pass invert=False (--no-invert) for the hardware convention;
    - the panel weights plane 0 as the MSB (2*p0 + p1); this computes
      p0 + 2*p1.
    See docs/dmd_graphics.md.
    """
    data_offset = frame_info['data_offset']
    frame_data = rom_data[data_offset:data_offset + FRAME_DATA_SIZE]
    
    if len(frame_data) < FRAME_DATA_SIZE:
        return np.zeros((DMD_HEIGHT, DMD_WIDTH), dtype=np.uint8)
    
    # Split into two planes
    plane0 = frame_data[:512]
    plane1 = frame_data[512:1024]
    
    # Create output array
    image = np.zeros((DMD_HEIGHT, DMD_WIDTH), dtype=np.uint8)
    
    for row in range(DMD_HEIGHT):
        row_offset = row * BYTES_PER_ROW
        for byte_idx in range(BYTES_PER_ROW):
            b0 = plane0[row_offset + byte_idx]
            b1 = plane1[row_offset + byte_idx]
            
            # Optional inversion; on IO Moon a SET bit is lit, so the
            # hardware convention is invert=False (see the docstring)
            if invert:
                b0 = ~b0 & 0xFF
                b1 = ~b1 & 0xFF
            
            for bit in range(8):
                col = byte_idx * 8 + (7 - bit)  # MSB first
                p0_bit = (b0 >> bit) & 1
                p1_bit = (b1 >> bit) & 1
                image[row, col] = p0_bit + 2 * p1_bit
    
    return image


def decode_static_screen(data: bytes, invert: bool = False) -> np.ndarray:
    """
    Decode a static DMD screen (1 bitplane, no header).
    Returns array with values 0 or 3 (off or full bright).
    
    For IO Moon static screens:
    - Bit value 1 = lit pixel (orange)
    - Bit value 0 = off pixel (black)
    - MSB is leftmost pixel in each byte
    """
    image = np.zeros((DMD_HEIGHT, DMD_WIDTH), dtype=np.uint8)
    
    for row in range(DMD_HEIGHT):
        row_offset = row * BYTES_PER_ROW
        for byte_idx in range(BYTES_PER_ROW):
            if row_offset + byte_idx >= len(data):
                continue
            b = data[row_offset + byte_idx]
            if invert:
                b = ~b & 0xFF
            for bit in range(8):
                col = byte_idx * 8 + (7 - bit)  # MSB first
                if (b >> bit) & 1:
                    image[row, col] = 3  # Full brightness
    
    return image


def decode_any_frame(rom_data: bytes, frame_info: dict, invert: bool = True) -> np.ndarray:
    """Decode either animated, static, or credits frame based on type."""
    frame_type = frame_info.get('type', 'animated')
    
    if frame_type == 'static':
        data = rom_data[frame_info['data_offset']:frame_info['data_offset']+STATIC_SCREEN_SIZE]
        # Static screens in IO Moon: 1=lit, no inversion needed
        return decode_static_screen(data, invert=False)
    elif frame_type == 'credits':
        # Credits frames have variable height, use dedicated decoder
        return decode_credits_frame(rom_data, frame_info)
    else:
        # Animated frames may need inversion
        return decode_frame(rom_data, frame_info, invert=invert)


def apply_dmd_dot_effect(image: np.ndarray) -> np.ndarray:
    """
    Upscale a DMD image and add dark gaps between pixels for authentic look.

    Each logical DMD pixel becomes a (scale × scale) block in the output,
    where the last 'gap' rows and columns are set to black (value 0).
    This simulates the physical pixel spacing on a real pinball DMD.

    Uses the module-level DMD_DOT_SCALE and DMD_DOT_GAP settings.

    Args:
        image: numpy array (H × W) with values 0-3.

    Returns:
        Upscaled numpy array (H*scale × W*scale) with black gaps between dots.
    """
    scale = DMD_DOT_SCALE
    gap = DMD_DOT_GAP

    if scale <= 1 and gap <= 0:
        return image

    h, w = image.shape
    upscaled = np.repeat(np.repeat(image, scale, axis=0), scale, axis=1)

    # Set the last 'gap' pixel rows/columns within each cell to 0 (black)
    if gap > 0:
        mask_y = np.arange(h * scale) % scale >= (scale - gap)
        mask_x = np.arange(w * scale) % scale >= (scale - gap)
        upscaled[mask_y, :] = 0
        upscaled[:, mask_x] = 0

    return upscaled


def create_dmd_colormap():
    """Create a custom colormap for DMD display."""
    return mcolors.ListedColormap(DMD_COLORS)


def format_offset(offset: int, include_rom1: bool = False) -> str:
    """Format an offset as hex string, optionally showing ROM1 offset."""
    if include_rom1 and offset >= ROM1_OFFSET:
        rom1_off = offset - ROM1_OFFSET
        return f"0x{offset:05X} (ROM1: 0x{rom1_off:05X})"
    return f"0x{offset:05X}"


def show_frame(rom_data: bytes, frame_info: dict, title: str = None, invert: bool = True):
    """Display a single DMD frame with hex offset in title."""
    image = decode_any_frame(rom_data, frame_info, invert=invert)
    display = apply_dmd_dot_effect(image)
    
    fig, ax = plt.subplots(figsize=(10, 4))
    cmap = create_dmd_colormap()
    
    ax.imshow(display, cmap=cmap, vmin=0, vmax=3, interpolation='nearest', aspect='equal')
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_facecolor('black')
    fig.patch.set_facecolor('black')
    
    # Always show offset in title
    offset_str = format_offset(frame_info['offset'], include_rom1=True)
    frame_type = frame_info.get('type', 'animated')
    if title:
        full_title = f"{title}\nOffset: {offset_str} [{frame_type}]"
    else:
        full_title = f"Offset: {offset_str} [{frame_type}]"
    
    ax.set_title(full_title, color=DMD_ORANGE, fontsize=11)
    
    plt.tight_layout()
    plt.show()


def show_all_frames(rom_data: bytes, frames: list, interval: int = 200, invert: bool = True):
    """Show all DMD frames in an animation using FuncAnimation."""
    if not frames:
        print("No frames found!")
        return
    
    # Check if we have an interactive backend
    backend = matplotlib.get_backend().lower()
    is_interactive = any(x in backend for x in ['tk', 'qt', 'gtk', 'wx', 'macosx', 'nbag'])
    
    if not is_interactive:
        print(f"Warning: Non-interactive backend '{backend}' detected.")
        print("Try using --loop flag for animation, or use --grid to view multiple frames.")
        print("Falling back to loop-based animation...")
        show_all_frames_loop(rom_data, frames, interval, invert)
        return
    
    # Use interactive mode
    plt.ion()
    
    fig, ax = plt.subplots(figsize=(10, 4))
    cmap = create_dmd_colormap()
    
    # Initialize with first frame
    image = decode_any_frame(rom_data, frames[0], invert=invert)
    display = apply_dmd_dot_effect(image)
    im = ax.imshow(display, cmap=cmap, vmin=0, vmax=3, interpolation='nearest', aspect='equal')
    
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_facecolor('black')
    fig.patch.set_facecolor('black')
    
    # Show offset in title
    offset_str = format_offset(frames[0]['offset'], include_rom1=True)
    title = ax.set_title(f"Frame 0/{len(frames)} - {offset_str}", 
                         color=DMD_ORANGE, fontsize=12)
    plt.tight_layout()
    
    def init():
        return [im, title]
    
    def update(frame_idx):
        frame = frames[frame_idx]
        image = decode_any_frame(rom_data, frame, invert=invert)
        im.set_array(apply_dmd_dot_effect(image))
        offset_str = format_offset(frame['offset'], include_rom1=True)
        title.set_text(f"Frame {frame_idx}/{len(frames)} - {offset_str}")
        return [im, title]
    
    # Create animation with init_func for better compatibility
    ani = FuncAnimation(
        fig, 
        update, 
        init_func=init,
        frames=len(frames), 
        interval=interval, 
        blit=True,
        repeat=True,
        cache_frame_data=False
    )
    
    # Store animation reference to prevent garbage collection
    fig._ani = ani
    plt.gcf()._ani = ani
    
    # Show with blocking to keep window open
    plt.ioff()
    plt.show()


def show_all_frames_manual(rom_data: bytes, frames: list, invert: bool = True):
    """Manual frame-by-frame viewer for non-interactive backends."""
    cmap = create_dmd_colormap()
    
    frame_idx = 0
    while True:
        fig, ax = plt.subplots(figsize=(10, 4))
        
        frame = frames[frame_idx]
        image = decode_any_frame(rom_data, frame, invert=invert)
        display = apply_dmd_dot_effect(image)
        
        ax.imshow(display, cmap=cmap, vmin=0, vmax=3, interpolation='nearest', aspect='equal')
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_facecolor('black')
        fig.patch.set_facecolor('black')
        
        offset_str = format_offset(frame['offset'], include_rom1=True)
        ax.set_title(f"Frame {frame_idx}/{len(frames)} - {offset_str}", 
                     color=DMD_ORANGE, fontsize=12)
        
        plt.tight_layout()
        plt.savefig('/tmp/dmd_frame.png', facecolor='black', edgecolor='black')
        plt.close()
        
        print(f"Frame {frame_idx}/{len(frames)} - {offset_str} - saved to /tmp/dmd_frame.png")
        
        try:
            user_input = input("Enter=next, number=goto frame, p=prev, q=quit: ").strip().lower()
        except EOFError:
            break
            
        if user_input == 'q':
            break
        elif user_input == 'p':
            frame_idx = max(0, frame_idx - 1)
        elif user_input == '':
            frame_idx = (frame_idx + 1) % len(frames)
        else:
            try:
                frame_idx = int(user_input) % len(frames)
            except ValueError:
                pass


def show_all_frames_loop(rom_data: bytes, frames: list, interval: int = 200, invert: bool = True):
    """
    Show all DMD frames using a manual plt.pause() loop.
    This is more reliable than FuncAnimation on some systems.
    Press Ctrl+C to stop.
    """
    if not frames:
        print("No frames found!")
        return
    
    print(f"Playing {len(frames)} frames at {interval}ms interval. Press Ctrl+C to stop.")
    
    plt.ion()  # Interactive mode on
    
    fig, ax = plt.subplots(figsize=(10, 4))
    cmap = create_dmd_colormap()
    
    # Initialize with first frame
    image = decode_any_frame(rom_data, frames[0], invert=invert)
    display = apply_dmd_dot_effect(image)
    im = ax.imshow(display, cmap=cmap, vmin=0, vmax=3, interpolation='nearest', aspect='equal')
    
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_facecolor('black')
    fig.patch.set_facecolor('black')
    
    offset_str = format_offset(frames[0]['offset'], include_rom1=True)
    title = ax.set_title(f"Frame 0/{len(frames)} - {offset_str}", 
                         color=DMD_ORANGE, fontsize=12)
    
    plt.tight_layout()
    plt.show(block=False)
    
    try:
        frame_idx = 0
        while True:
            frame = frames[frame_idx]
            image = decode_any_frame(rom_data, frame, invert=invert)
            im.set_array(apply_dmd_dot_effect(image))
            offset_str = format_offset(frame['offset'], include_rom1=True)
            title.set_text(f"Frame {frame_idx}/{len(frames)} - {offset_str}")
            
            fig.canvas.draw()
            fig.canvas.flush_events()
            plt.pause(interval / 1000.0)
            
            frame_idx = (frame_idx + 1) % len(frames)
            
            # Check if window was closed
            if not plt.fignum_exists(fig.number):
                break
                
    except KeyboardInterrupt:
        print("\nAnimation stopped.")
    finally:
        plt.ioff()
        plt.close(fig)


def show_index(frames: list, show_static: bool = False):
    """Display the frame index table."""
    print(f"\n{'='*70}")
    if show_static:
        print(f"DMD Static Screen Index - Total: {len(frames)} screens")
    else:
        print(f"DMD Animated Frame Index - Total: {len(frames)} frames")
    print(f"{'='*70}")
    print(f"{'Index':>6}  {'Offset':>12}  {'ROM1 Offset':>12}  {'Type':>10}  {'Pixels':>8}")
    print(f"{'-'*6}  {'-'*12}  {'-'*12}  {'-'*10}  {'-'*8}")
    
    for frame in frames:
        offset = frame['offset']
        rom1_off = offset - ROM1_OFFSET if offset >= ROM1_OFFSET else offset
        frame_type = frame.get('type', 'animated')
        pixels = frame.get('lit_pixels', '-')
        print(f"{frame['index']:6d}  0x{offset:08X}  0x{rom1_off:08X}  {frame_type:>10}  {pixels:>8}")
    
    print(f"\n{'='*70}")
    if not show_static:
        print(f"Frame structure:")
        print(f"  Header: {FRAME_HEADER.hex(' ')}")
        print(f"  Header size: {FRAME_HEADER_SIZE} bytes")
        print(f"  Data size: {FRAME_DATA_SIZE} bytes (2 planes Ã— 512 bytes)")
        print(f"  Total frame size: {FRAME_TOTAL_SIZE} bytes")
    else:
        print(f"Static screen structure:")
        print(f"  No header (raw bitmap data)")
        print(f"  Data size: {STATIC_SCREEN_SIZE} bytes (1 plane Ã— 512 bytes)")
    print(f"  Resolution: {DMD_WIDTH}Ã—{DMD_HEIGHT} pixels")
    print(f"{'='*70}\n")


def show_frame_by_offset(rom_data: bytes, offset: int, invert: bool = True, is_static: bool = False):
    """Display a frame at a specific offset."""
    if is_static:
        frame_info = {
            'index': -1,
            'offset': offset,
            'data_offset': offset,
            'type': 'static',
        }
        show_frame(rom_data, frame_info, 
                   title=f"Static Screen", invert=invert)
    elif rom_data[offset:offset+FRAME_HEADER_SIZE] == FRAME_HEADER:
        frame_info = {
            'index': -1,
            'offset': offset,
            'header_offset': offset,
            'data_offset': offset + FRAME_HEADER_SIZE,
            'type': 'animated',
        }
        show_frame(rom_data, frame_info, 
                   title=f"Animated Frame", invert=invert)
    else:
        # Try to display as static screen
        print(f"No animated frame header at offset 0x{offset:05X}")
        print(f"Found: {rom_data[offset:offset+6].hex(' ')}")
        print(f"Expected: {FRAME_HEADER.hex(' ')}")
        print("Displaying as static screen...")
        
        frame_info = {
            'index': -1,
            'offset': offset,
            'data_offset': offset,
            'type': 'static',
        }
        show_frame(rom_data, frame_info, 
                   title=f"Data at offset", invert=invert)


def find_fonts(rom_data: bytes) -> dict:
    """
    Find and analyze font data in the ROM.
    
    ROM Font Structure (Discovered via reverse engineering):
    - Font entries have a 6-byte header: [height, 0, 1, 0, height, 0]
    - Followed by 2 copies of the glyph bitmap (2 * height bytes)
    - Font entries found in ROM starting around 0xA02B2
    
    Font entry structure:
    - Entry 0-9 (h=9): Digits 0-9 (small 9px font)
    - Entry 10 (h=9): Space
    - Entry 11-37 (h=9): Letters A-Z and Ã‘ (small font)
    - Entry 38-51 (h=9): Punctuation and symbols
    - Entry 52-61 (h=12): Digits 0-9 (large 12px font)  
    - Entry 62 (h=12): Space
    - Entry 63-89 (h=12): Letters A-Z and Ã‘ (large font)
    - Entry 90-104 (h=12): Punctuation and symbols
    - Entry 105-125 (h=12): 7-segment style digits
    - Entry 126+ (h=10): Extra large characters
    """
    fonts = {
        'entries': [],  # List of (offset, height, glyph_data)
        'entry_chars': {},  # Mapping from entry index to character
    }
    
    # Scan ROM for font entry headers
    scan_ranges = [(0xA0000, 0xB0000)]  # Main font area
    
    for scan_start, scan_end in scan_ranges:
        last_end = scan_start
        for offset in range(scan_start, min(scan_end, len(rom_data) - 6)):
            if offset < last_end:
                continue
                
            header = rom_data[offset:offset+6]
            if len(header) < 6:
                break
            
            h1, z1, one, z2, h2, z3 = header
            # Valid header: height in [9,10,11,12], pattern: h 00 01 00 h 00
            if h1 in [9, 10, 11, 12] and h2 == h1 and z1 == 0 and one == 1 and z2 == 0 and z3 == 0:
                height = h1
                glyph_offset = offset + 6
                glyph_data = bytes(rom_data[glyph_offset:glyph_offset + height])
                
                fonts['entries'].append({
                    'offset': offset,
                    'glyph_offset': glyph_offset,
                    'height': height,
                    'width': 8,
                    'glyph_data': glyph_data,
                })
                
                # Skip past this entry to avoid overlaps
                # Entry size: 6 header + 2*height glyphs + ~6 padding
                entry_size = 6 + 2 * height + 6
                last_end = offset + entry_size
    
    # Create character mapping based on visual identification
    # Small font (9px) - entries 0-51
    # Verified by visual inspection of each glyph
    small_chars = (
        '0123456789 '           # 0-10: digits and space
        'ABCDEFGHIJKLMNÃ‘OPQRSTUVWXYZ'  # 11-37: letters (Ã‘ after N)
        '+ç()/'                 # 38-42: + ç ( ) /
        ',.;:-""¿¡'             # 43-51: , . ; : - " " ¿ ¡
    )
    
    # Large font (12px) - entries 52-104
    # Fixed based on visual analysis - entry by entry verification
    large_chars = (
        '0123456789 '           # 52-62: digits and space
        'ABCDEFGHIJKLMNÃ‘OPQRSTUVWXYZ'  # 63-89: letters (Ã‘ after N)
        '+ç()/'                 # 90-94: + ç ( ) /
        ',.;:-""¿?←'            # 95-104: , . ; : - " " ¿ ? ←
    )
    
    # 7-segment style (12px) - entries 105-125
    seven_seg_chars = '0123456789:0123456789:'
    
    # Extra large (10px) - entries 126-130
    # These are large stylized digits: 0, 2, 4, 6, 8
    extra_large_chars = '02468'
    
    # Build character mapping
    for i, char in enumerate(small_chars):
        if i < len(fonts['entries']):
            fonts['entry_chars'][i] = char
    
    for i, char in enumerate(large_chars):
        idx = 52 + i
        if idx < len(fonts['entries']):
            fonts['entry_chars'][idx] = char
    
    for i, char in enumerate(seven_seg_chars):
        idx = 105 + i
        if idx < len(fonts['entries']):
            fonts['entry_chars'][idx] = char
    
    for i, char in enumerate(extra_large_chars):
        idx = 126 + i
        if idx < len(fonts['entries']):
            fonts['entry_chars'][idx] = char
    
    return fonts


def decode_glyph(rom_data: bytes, entry: dict) -> np.ndarray:
    """Decode a single glyph bitmap from a font entry."""
    glyph_data = entry['glyph_data']
    height = entry['height']
    width = entry['width']
    
    image = np.zeros((height, width), dtype=np.uint8)
    
    for y in range(min(height, len(glyph_data))):
        byte = glyph_data[y]
        for x in range(8):
            if byte & (0x80 >> x):
                image[y, x] = 3  # Bright orange
    
    return image


def decode_glyph_by_index(rom_data: bytes, fonts: dict, entry_index: int) -> np.ndarray:
    """Decode a glyph by its entry index."""
    if 0 <= entry_index < len(fonts['entries']):
        return decode_glyph(rom_data, fonts['entries'][entry_index])
    return np.zeros((12, 8), dtype=np.uint8)


class PaginatedFontViewer:
    """Interactive paginated font viewer with keyboard navigation."""
    
    def __init__(self, rom_data, fonts, cols=12, rows=8):
        self.rom_data = rom_data
        self.fonts = fonts
        self.cols = cols
        self.rows = rows
        self.items_per_page = cols * rows
        self.current_page = 0
        self.entries = fonts['entries']
        self.entry_chars = fonts['entry_chars']
        self.total_pages = (len(self.entries) + self.items_per_page - 1) // self.items_per_page
        self.filter_mode = 'all'  # 'all', 'small', 'large', '7seg'
        
        self.fig = None
        self.axes = None
        self.cmap = create_dmd_colormap()
    
    def get_filtered_entries(self):
        """Get entries based on current filter mode."""
        if self.filter_mode == 'all':
            return list(range(len(self.entries)))
        elif self.filter_mode == 'small':
            return [i for i, e in enumerate(self.entries) if e['height'] == 9]
        elif self.filter_mode == 'large':
            return [i for i, e in enumerate(self.entries) if e['height'] == 12 and i < 105]
        elif self.filter_mode == '7seg':
            return [i for i, e in enumerate(self.entries) if i >= 105]
        return list(range(len(self.entries)))
    
    def draw_page(self):
        """Draw the current page of glyphs."""
        filtered = self.get_filtered_entries()
        start_idx = self.current_page * self.items_per_page
        end_idx = min(start_idx + self.items_per_page, len(filtered))
        
        total_pages = (len(filtered) + self.items_per_page - 1) // self.items_per_page
        
        for idx, ax in enumerate(self.axes.flat):
            display_idx = start_idx + idx
            if display_idx < end_idx:
                entry_idx = filtered[display_idx]
                entry = self.entries[entry_idx]
                char = self.entry_chars.get(entry_idx, '?')
                height = entry['height']
                offset = entry['offset']
                
                # Decode and display glyph
                image = decode_glyph(self.rom_data, entry)
                display = apply_dmd_dot_effect(image)
                
                ax.clear()
                ax.imshow(display, cmap=self.cmap, vmin=0, vmax=3, 
                         interpolation='nearest', aspect='equal')
                ax.set_title(f"'{char}' #{entry_idx}\n{height}px @{offset:05X}", 
                           color=DMD_ORANGE, fontsize=7)
                ax.set_visible(True)
            else:
                ax.clear()
                ax.set_visible(False)
            ax.set_xticks([])
            ax.set_yticks([])
            ax.set_facecolor('black')
        
        # Update main title
        mode_names = {'all': 'All Fonts', 'small': 'Small (9px)', 
                      'large': 'Large (12px)', '7seg': '7-Segment'}
        self.fig.suptitle(
            f'{mode_names[self.filter_mode]} | '
            f'Entries {start_idx}-{end_idx-1} of {len(filtered)} '
            f'(Page {self.current_page+1}/{total_pages})\n'
            f'[Space/Right: Next | Left: Prev | 1-4: Filter | q: Quit]',
            color=DMD_ORANGE, fontsize=11
        )
        
        self.fig.canvas.draw()
    
    def on_key(self, event):
        """Handle keyboard events."""
        filtered = self.get_filtered_entries()
        total_pages = (len(filtered) + self.items_per_page - 1) // self.items_per_page
        
        if event.key in [' ', 'right', 'n']:
            if self.current_page < total_pages - 1:
                self.current_page += 1
                self.draw_page()
        elif event.key in ['backspace', 'left', 'p']:
            if self.current_page > 0:
                self.current_page -= 1
                self.draw_page()
        elif event.key == 'home':
            self.current_page = 0
            self.draw_page()
        elif event.key == 'end':
            self.current_page = total_pages - 1
            self.draw_page()
        elif event.key == '1':
            self.filter_mode = 'all'
            self.current_page = 0
            self.draw_page()
        elif event.key == '2':
            self.filter_mode = 'small'
            self.current_page = 0
            self.draw_page()
        elif event.key == '3':
            self.filter_mode = 'large'
            self.current_page = 0
            self.draw_page()
        elif event.key == '4':
            self.filter_mode = '7seg'
            self.current_page = 0
            self.draw_page()
        elif event.key == 'q':
            plt.close(self.fig)
    
    def show(self):
        """Display the paginated font viewer."""
        self.fig, self.axes = plt.subplots(self.rows, self.cols, figsize=(18, 12))
        self.fig.patch.set_facecolor('black')
        
        self.fig.canvas.mpl_connect('key_press_event', self.on_key)
        
        self.draw_page()
        plt.tight_layout()
        plt.show()


def show_fonts(rom_data: bytes):
    """Display font information with interactive paginated glyph viewer."""
    fonts = find_fonts(rom_data)
    
    print(f"\n{'='*70}")
    print("DMD Font Information (Reverse Engineered)")
    print(f"{'='*70}")
    print(f"Total font entries found: {len(fonts['entries'])}")
    
    # Count entries by height
    height_counts = {}
    for entry in fonts['entries']:
        h = entry['height']
        height_counts[h] = height_counts.get(h, 0) + 1
    
    print("\nFont breakdown by height:")
    for h, count in sorted(height_counts.items()):
        print(f"  {h}px: {count} glyphs")
    
    print("\nFont entry structure:")
    print("  Entry   0-9   (9px):  Digits 0-9 (small font)")
    print("  Entry  10     (9px):  Space")
    print("  Entry  11-37  (9px):  Letters A-Z, Ã‘ (small font)")
    print("  Entry  38-51  (9px):  Punctuation")
    print("  Entry  52-61  (12px): Digits 0-9 (large font)")
    print("  Entry  62     (12px): Space")
    print("  Entry  63-89  (12px): Letters A-Z, Ã‘ (large font)")
    print("  Entry  90-104 (12px): Punctuation")
    print("  Entry 105-125 (12px): 7-segment style digits")
    print("  Entry 126+    (10px): Extra large characters")
    
    print(f"\n{'='*70}")
    print("Sample glyphs:")
    print(f"{'='*70}")
    
    for i in range(len(fonts['entries'])):
        entry = fonts['entries'][i]
        char = fonts['entry_chars'].get(i, '?')
        print(f"Entry {i:3d}: '{char}' (h={entry['height']}px) @ 0x{entry['offset']:05X}")
    
    print(f"\n{'='*70}")
    print("\nOpening interactive glyph viewer...")
    print("Navigation: Space/Right=Next, Left=Prev, q=Quit")
    print("Filters:    1=All, 2=Small(9px), 3=Large(12px), 4=7-Segment")
    
    # Show paginated glyph viewer
    viewer = PaginatedFontViewer(rom_data, fonts)
    viewer.show()


class PaginatedGrid:
    """Interactive paginated grid viewer with keyboard navigation."""
    
    def __init__(self, rom_data, frames, cols=8, rows=4, invert=True, title_prefix="Frames"):
        self.rom_data = rom_data
        self.frames = frames
        self.cols = cols
        self.rows = rows
        self.items_per_page = cols * rows
        self.invert = invert
        self.title_prefix = title_prefix
        self.current_page = 0
        self.total_pages = (len(frames) + self.items_per_page - 1) // self.items_per_page
        
        self.fig = None
        self.axes = None
        self.cmap = create_dmd_colormap()
        
    def draw_page(self):
        """Draw the current page of frames."""
        start_idx = self.current_page * self.items_per_page
        end_idx = min(start_idx + self.items_per_page, len(self.frames))
        
        for idx, ax in enumerate(self.axes.flat):
            frame_idx = start_idx + idx
            if frame_idx < end_idx:
                frame = self.frames[frame_idx]
                image = decode_any_frame(self.rom_data, frame, invert=self.invert)
                display = apply_dmd_dot_effect(image)
                ax.clear()
                ax.imshow(display, cmap=self.cmap, vmin=0, vmax=3, interpolation='nearest')
                
                # Show frame number and offset
                offset_hex = f"0x{frame['offset']:05X}"
                ax.set_title(f'#{frame_idx}\n{offset_hex}', color=DMD_ORANGE, fontsize=7)
                ax.set_visible(True)
            else:
                ax.clear()
                ax.set_visible(False)
            ax.set_xticks([])
            ax.set_yticks([])
            ax.set_facecolor('black')
        
        # Update main title
        self.fig.suptitle(
            f'{self.title_prefix} {start_idx}-{end_idx-1} of {len(self.frames)} '
            f'(Page {self.current_page+1}/{self.total_pages})\n'
            f'[Space/Right: Next | Left: Prev | q: Quit]',
            color=DMD_ORANGE, fontsize=12
        )
        
        self.fig.canvas.draw()
    
    def on_key(self, event):
        """Handle keyboard events."""
        if event.key in [' ', 'right', 'n']:
            if self.current_page < self.total_pages - 1:
                self.current_page += 1
                self.draw_page()
        elif event.key in ['backspace', 'left', 'p']:
            if self.current_page > 0:
                self.current_page -= 1
                self.draw_page()
        elif event.key == 'home':
            self.current_page = 0
            self.draw_page()
        elif event.key == 'end':
            self.current_page = self.total_pages - 1
            self.draw_page()
        elif event.key == 'q':
            plt.close(self.fig)
    
    def show(self, start_page=0):
        """Display the paginated grid."""
        self.current_page = min(start_page, self.total_pages - 1)
        
        self.fig, self.axes = plt.subplots(self.rows, self.cols, figsize=(16, 8))
        self.fig.patch.set_facecolor('black')
        
        self.fig.canvas.mpl_connect('key_press_event', self.on_key)
        
        self.draw_page()
        plt.tight_layout()
        plt.show()


def show_grid(rom_data: bytes, frames: list, start_frame: int = 0, 
              cols: int = 8, rows: int = 4, invert: bool = True,
              paginated: bool = True, title_prefix: str = "Frames"):
    """Display multiple frames in a grid layout with optional pagination."""
    
    if paginated and len(frames) > cols * rows:
        start_page = start_frame // (cols * rows)
        viewer = PaginatedGrid(rom_data, frames, cols, rows, invert, title_prefix)
        viewer.show(start_page)
    else:
        total_frames = cols * rows
        end_frame = min(start_frame + total_frames, len(frames))
        
        fig, axes = plt.subplots(rows, cols, figsize=(16, 8))
        cmap = create_dmd_colormap()
        
        for idx, ax in enumerate(axes.flat):
            frame_idx = start_frame + idx
            if frame_idx < end_frame:
                frame = frames[frame_idx]
                image = decode_any_frame(rom_data, frame, invert=invert)
                display = apply_dmd_dot_effect(image)
                ax.imshow(display, cmap=cmap, vmin=0, vmax=3, interpolation='nearest')
                offset_hex = f"0x{frame['offset']:05X}"
                ax.set_title(f'#{frame_idx}\n{offset_hex}', color=DMD_ORANGE, fontsize=7)
            else:
                ax.set_visible(False)
            ax.set_xticks([])
            ax.set_yticks([])
            ax.set_facecolor('black')
        
        fig.patch.set_facecolor('black')
        plt.suptitle(f'{title_prefix} {start_frame}-{end_frame-1}', color=DMD_ORANGE, fontsize=14)
        plt.tight_layout()
        plt.show()


def export_frame_png(rom_data: bytes, frame_info: dict, output_path: str, invert: bool = True):
    """Export a single frame as PNG with dot matrix effect."""
    image = decode_any_frame(rom_data, frame_info, invert=invert)
    display = apply_dmd_dot_effect(image)
    
    h, w = display.shape
    rgb_image = np.zeros((h, w, 3), dtype=np.uint8)
    for val, color in enumerate(DMD_COLORS):
        r = int(color[1:3], 16)
        g = int(color[3:5], 16)
        b = int(color[5:7], 16)
        rgb_image[display == val] = [r, g, b]
    
    plt.imsave(output_path, rgb_image)
    print(f"Exported: {output_path} (offset: 0x{frame_info['offset']:05X})")


def export_all_frames(rom_data: bytes, frames: list, output_dir: str, invert: bool = True):
    """Export all frames as PNG files."""
    import os
    os.makedirs(output_dir, exist_ok=True)
    
    for i, frame in enumerate(frames):
        frame_type = frame.get('type', 'animated')
        output_path = os.path.join(output_dir, f"frame_{i:04d}_{frame_type}_0x{frame['offset']:05X}.png")
        image = decode_any_frame(rom_data, frame, invert=invert)
        display = apply_dmd_dot_effect(image)
        
        h, w = display.shape
        rgb_image = np.zeros((h, w, 3), dtype=np.uint8)
        for val, color in enumerate(DMD_COLORS):
            r = int(color[1:3], 16)
            g = int(color[3:5], 16)
            b = int(color[5:7], 16)
            rgb_image[display == val] = [r, g, b]
        
        plt.imsave(output_path, rgb_image)
        
        if (i + 1) % 50 == 0:
            print(f"Exported {i + 1}/{len(frames)} frames...")
    
    print(f"\nExported {len(frames)} frames to {output_dir}/")


def main():
    parser = argparse.ArgumentParser(
        description='IO Moon Pinball DMD Viewer',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -r io_moon.bin --index              Show animated frame index
  %(prog)s -r io_moon.bin --static-index       Show static screen index
  %(prog)s -r io_moon.bin --known              List all known/named screens
  %(prog)s -r io_moon.bin --known-grid         Show known screens in grid
  %(prog)s -r io_moon.bin --show-all           Animate all frames  
  %(prog)s -r io_moon.bin --show-all --loop    Use manual loop (more reliable)
  %(prog)s -r io_moon.bin --frame 0            Show animated frame by index
  %(prog)s -r io_moon.bin --static 0           Show static screen by index
  %(prog)s -r io_moon.bin --offset 0x00406     Show frame at offset
  %(prog)s -r io_moon.bin --offset 0xBB409 --static-offset  Show static at offset
  %(prog)s -r io_moon.bin --fonts              Show font information
  %(prog)s -r io_moon.bin --grid               Show frames in paginated grid
  %(prog)s -r io_moon.bin --static-grid        Show static screens in grid
  %(prog)s -r io_moon.bin --export 0 out.png   Export frame 0 as PNG
  %(prog)s -r io_moon.bin --no-invert          Show without bit inversion
  %(prog)s -r io_moon.bin --no-dots --frame 0  Show without dot spacing
  %(prog)s -r io_moon.bin --dot-scale 6 --dot-gap 2  Larger dots

Grid Navigation:
  Space/Right Arrow/n : Next page
  Backspace/Left/p    : Previous page
  Home                : First page
  End                 : Last page
  q                   : Quit
        """
    )
    
    parser.add_argument('-r', '--rom', required=True, type=str,
                        help='Path to the ROM file')
    
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--index', action='store_true',
                        help='Show animated frame index table')
    action.add_argument('--static-index', action='store_true',
                        help='Show static screen index table')
    action.add_argument('--show-all', action='store_true',
                        help='Animate all DMD frames')
    action.add_argument('--frame', type=int, metavar='N',
                        help='Show animated frame by index number')
    action.add_argument('--static', type=int, metavar='N',
                        help='Show static screen by index number')
    action.add_argument('--offset', type=str, metavar='ADDR',
                        help='Show frame at specific offset (hex, e.g., 0x00406)')
    action.add_argument('--fonts', action='store_true',
                        help='Show font information and glyphs')
    action.add_argument('--export', nargs=2, metavar=('FRAME', 'FILE'),
                        help='Export frame N to PNG file')
    action.add_argument('--export-all', type=str, metavar='DIR',
                        help='Export all frames as PNG files to directory')
    action.add_argument('--grid', type=int, metavar='START', nargs='?', const=0,
                        help='Show animated frames in paginated grid (default: start at 0)')
    action.add_argument('--static-grid', type=int, metavar='START', nargs='?', const=0,
                        help='Show static screens in paginated grid')
    action.add_argument('--known', action='store_true',
                        help='List all known/named static screens')
    action.add_argument('--known-grid', action='store_true',
                        help='Show all known static screens in a grid')
    action.add_argument('--credits', action='store_true',
                        help='Show scrolling credits animation screens')
    action.add_argument('--credits-index', action='store_true',
                        help='List all credits screens with offsets')
    action.add_argument('--credits-grid', type=int, metavar='START', nargs='?', const=0,
                        help='Show credits screens in paginated grid')
    
    parser.add_argument('--interval', type=int, default=200,
                        help='Animation interval in ms (default: 200)')
    parser.add_argument('--no-invert', action='store_true',
                        help='Do not invert bits (default: invert, 0=lit)')
    parser.add_argument('--rows', type=int, default=4,
                        help='Number of rows in grid view (default: 4)')
    parser.add_argument('--cols', type=int, default=8,
                        help='Number of columns in grid view (default: 8)')
    parser.add_argument('--loop', action='store_true',
                        help='Use manual loop for animation instead of FuncAnimation')
    parser.add_argument('--static-offset', action='store_true',
                        help='Treat --offset as static screen (no header)')
    parser.add_argument('--no-paginate', action='store_true',
                        help='Disable grid pagination (show single page only)')
    parser.add_argument('--dot-scale', type=int, default=None,
                        help='DMD dot size in output pixels (default: 4, 1=no upscale)')
    parser.add_argument('--dot-gap', type=int, default=None,
                        help='Dark gap between dots in pixels (default: 1, 0=no gap)')
    parser.add_argument('--no-dots', action='store_true',
                        help='Disable dot matrix effect (flat pixel rendering)')
    
    args = parser.parse_args()
    
    # Apply dot matrix effect settings to module-level constants
    global DMD_DOT_SCALE, DMD_DOT_GAP
    if args.no_dots:
        DMD_DOT_SCALE = 1
        DMD_DOT_GAP = 0
    else:
        if args.dot_scale is not None:
            DMD_DOT_SCALE = max(1, args.dot_scale)
        if args.dot_gap is not None:
            DMD_DOT_GAP = max(0, args.dot_gap)
    
    # Load ROM
    rom_path = Path(args.rom)
    if not rom_path.exists():
        print(f"Error: ROM file not found: {rom_path}")
        sys.exit(1)
    
    print(f"Loading ROM: {rom_path}")
    with open(rom_path, 'rb') as f:
        rom_data = f.read()
    print(f"ROM size: {len(rom_data)} bytes (0x{len(rom_data):X})")
    
    # Find frames
    frames = find_frames(rom_data)
    print(f"Found {len(frames)} animated DMD frames")
    
    # Find static screens if needed
    static_screens = None
    if args.static_index or args.static is not None or args.static_grid is not None:
        print("Scanning for static screens...")
        static_screens = find_static_screens(rom_data)
        print(f"Found {len(static_screens)} static screens")
    
    # Find credits if needed
    credits_screens = None
    if args.credits or args.credits_index or args.credits_grid is not None:
        print("Scanning for scrolling credits...")
        credits_screens = find_scrolling_credits(rom_data)
        print(f"Found {len(credits_screens)} credits screens")
    
    # Determine invert setting
    invert = not args.no_invert
    
    # Execute requested action
    if args.index:
        show_index(frames, show_static=False)
    
    elif args.static_index:
        if static_screens is None:
            static_screens = find_static_screens(rom_data)
        show_index(static_screens, show_static=True)
    
    elif args.show_all:
        print(f"Showing all {len(frames)} frames (interval: {args.interval}ms)")
        print("Close the window to exit.")
        if args.loop:
            show_all_frames_loop(rom_data, frames, interval=args.interval, invert=invert)
        else:
            show_all_frames(rom_data, frames, interval=args.interval, invert=invert)
    
    elif args.frame is not None:
        if 0 <= args.frame < len(frames):
            frame = frames[args.frame]
            print(f"Showing animated frame {args.frame} at offset 0x{frame['offset']:05X}")
            show_frame(rom_data, frame, 
                       title=f"Animated Frame {args.frame}",
                       invert=invert)
        else:
            print(f"Error: Frame index {args.frame} out of range (0-{len(frames)-1})")
            sys.exit(1)
    
    elif args.static is not None:
        if static_screens is None:
            static_screens = find_static_screens(rom_data)
        if 0 <= args.static < len(static_screens):
            screen = static_screens[args.static]
            print(f"Showing static screen {args.static} at offset 0x{screen['offset']:05X}")
            show_frame(rom_data, screen, 
                       title=f"Static Screen {args.static}",
                       invert=invert)
        else:
            print(f"Error: Static screen index {args.static} out of range (0-{len(static_screens)-1})")
            sys.exit(1)
    
    elif args.offset:
        try:
            offset = int(args.offset, 0)
        except ValueError:
            print(f"Error: Invalid offset format: {args.offset}")
            sys.exit(1)
        
        if offset < 0 or offset >= len(rom_data):
            print(f"Error: Offset 0x{offset:X} out of range")
            sys.exit(1)
        
        print(f"Showing data at offset 0x{offset:05X}")
        show_frame_by_offset(rom_data, offset, invert=invert, is_static=args.static_offset)
    
    elif args.fonts:
        show_fonts(rom_data)
    
    elif args.export:
        try:
            frame_idx = int(args.export[0])
            output_file = args.export[1]
        except ValueError:
            print(f"Error: Invalid frame number: {args.export[0]}")
            sys.exit(1)
        
        if 0 <= frame_idx < len(frames):
            export_frame_png(rom_data, frames[frame_idx], output_file, invert=invert)
        else:
            print(f"Error: Frame index {frame_idx} out of range (0-{len(frames)-1})")
            sys.exit(1)
    
    elif args.export_all:
        print(f"Exporting all {len(frames)} frames to {args.export_all}/")
        export_all_frames(rom_data, frames, args.export_all, invert=invert)
    
    elif args.grid is not None:
        start_frame = args.grid
        if start_frame < 0 or start_frame >= len(frames):
            print(f"Error: Start frame {start_frame} out of range (0-{len(frames)-1})")
            sys.exit(1)
        print(f"Showing animated frames grid (paginated)")
        print("Use Space/Arrow keys to navigate, 'q' to quit")
        show_grid(rom_data, frames, start_frame=start_frame, 
                  cols=args.cols, rows=args.rows, invert=invert,
                  paginated=not args.no_paginate, title_prefix="Animated Frames")
    
    elif args.static_grid is not None:
        if static_screens is None:
            static_screens = find_static_screens(rom_data)
        start_frame = args.static_grid
        if start_frame < 0 or start_frame >= len(static_screens):
            print(f"Error: Start index {start_frame} out of range (0-{len(static_screens)-1})")
            sys.exit(1)
        print(f"Showing static screens grid (paginated)")
        print("Use Space/Arrow keys to navigate, 'q' to quit")
        show_grid(rom_data, static_screens, start_frame=start_frame, 
                  cols=args.cols, rows=args.rows, invert=invert,
                  paginated=not args.no_paginate, title_prefix="Static Screens")
    
    elif args.known:
        # List known static screens
        print(f"\n{'='*70}")
        print(f"Known Static Screens - Total: {len(KNOWN_STATIC_SCREENS)}")
        print(f"{'='*70}")
        print(f"{'Idx':>4}  {'Offset':>10}  {'ROM1 Offset':>12}  Description")
        print(f"{'-'*4}  {'-'*10}  {'-'*12}  {'-'*40}")
        
        for idx, (offset, rom1_off, desc) in enumerate(KNOWN_STATIC_SCREENS):
            print(f"{idx:4d}  0x{offset:08X}  0x{rom1_off:08X}  {desc}")
        
        print(f"\n{'='*70}")
        print("Use --offset <ADDR> --static-offset to view any of these screens")
        print("Example: --offset 0xAA201 --static-offset")
        print(f"{'='*70}\n")
    
    elif args.known_grid:
        # Show known screens in a grid
        print(f"Showing {len(KNOWN_STATIC_SCREENS)} known static screens")
        
        # Create frame info list from known screens
        known_frames = []
        for idx, (offset, rom1_off, desc) in enumerate(KNOWN_STATIC_SCREENS):
            known_frames.append({
                'index': idx,
                'offset': offset,
                'data_offset': offset,
                'type': 'static',
                'description': desc
            })
        
        show_grid(rom_data, known_frames, start_frame=0,
                  cols=args.cols, rows=args.rows, invert=invert,
                  paginated=not args.no_paginate, title_prefix="Known Screens")
    
    elif args.credits_index:
        # List all credits screens
        if credits_screens is None:
            credits_screens = find_scrolling_credits(rom_data)
        
        print(f"\n{'='*70}")
        print(f"Scrolling Credits Screens - Total: {len(credits_screens)}")
        print(f"{'='*70}")
        print(f"{'Idx':>4}  {'Offset':>10}  {'ROM1 Offset':>12}  {'Height':>6}")
        print(f"{'-'*4}  {'-'*10}  {'-'*12}  {'-'*6}")
        
        for credit in credits_screens:
            offset = credit['offset']
            rom1_off = offset - ROM1_OFFSET if offset >= ROM1_OFFSET else offset
            height = credit['height']
            print(f"{credit['index']:4d}  0x{offset:08X}  0x{rom1_off:08X}  {height:6d}")
        
        print(f"\n{'='*70}")
        print("Use --credits-grid to view these screens")
        print(f"{'='*70}\n")
    
    elif args.credits or args.credits_grid is not None:
        if credits_screens is None:
            credits_screens = find_scrolling_credits(rom_data)
        
        if not credits_screens:
            print("No credits screens found")
            sys.exit(1)
        
        start_frame = args.credits_grid if args.credits_grid is not None else 0
        if start_frame < 0 or start_frame >= len(credits_screens):
            print(f"Error: Start index {start_frame} out of range (0-{len(credits_screens)-1})")
            sys.exit(1)
        
        print(f"Showing {len(credits_screens)} credits screens")
        print("Use Space/Arrow keys to navigate, 'q' to quit")
        
        # Convert credits to frame format for show_grid
        credits_frames = []
        for credit in credits_screens:
            credits_frames.append({
                'index': credit['index'],
                'offset': credit['offset'],
                'data_offset': credit['offset'],
                'type': 'credits',
                'height': credit['height'],
            })
        
        show_grid(rom_data, credits_frames, start_frame=start_frame,
                  cols=args.cols, rows=args.rows, invert=invert,
                  paginated=not args.no_paginate, title_prefix="Credits")


if __name__ == '__main__':
    main()