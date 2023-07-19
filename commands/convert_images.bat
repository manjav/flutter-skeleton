@ECHO OFF
setlocal enabledelayedexpansion
cd assets\\images
for %%f in (*.png) do (
  echo %%f converted to %%~nf.webp
  cwebp %%f -lossless -m 6 -o %%~nf.webp
  del %%f
)