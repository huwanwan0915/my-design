import struct, zlib, os
W,H = 3840,2160
pixels = bytearray([255,255,255,255]) * (W*H)

def clear_rect(x0,y0,x1,y1):
    x0=max(0,int(x0)); y0=max(0,int(y0)); x1=min(W,int(x1)); y1=min(H,int(y1))
    transparent = b'\x00\x00\x00\x00' * (x1-x0)
    for y in range(y0,y1):
        start=(y*W+x0)*4
        pixels[start:start+len(transparent)] = transparent

# Editable wood regions only, based on the 3840×2160 source.
clear_rect(20, 430, 585, 1125)       # left niche back/sides/top shelf wood
clear_rect(15, 1170, 610, 1510)      # left lower wood drawers
clear_rect(0, 540, 45, 1510)         # far-left wood return
clear_rect(575, 430, 660, 1510)      # left niche right wood jamb
clear_rect(1665, 420, 1785, 1305)    # central vertical wood slats
clear_rect(1590, 1025, 1788, 1515)   # central lower wood block
clear_rect(2075, 405, 2948, 1495)    # right bookcase wood back/shelves/drawers
clear_rect(2925, 410, 2995, 1495)    # right bookcase side return

def chunk(tag, data):
    return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag+data)&0xffffffff)
raw = bytearray()
stride=W*4
for y in range(H):
    raw.append(0)
    raw.extend(pixels[y*stride:(y+1)*stride])
png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', W,H,8,6,0,0,0)) + chunk(b'IDAT', zlib.compress(bytes(raw), 6)) + chunk(b'IEND', b'')
os.makedirs('tmp/imagegen', exist_ok=True)
path='tmp/imagegen/living-room-all-wood-ls72-mask.png'
open(path,'wb').write(png)
print(path, len(png))
