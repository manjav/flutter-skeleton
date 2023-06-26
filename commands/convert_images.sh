cd assets/images
for file in *.png;
 do (
    [ -e "$file" ] || continue
    echo \'$file\' converted to \'${file%.*}.webp\'
    cwebp $file -lossless -m 6 -o ${file%.*}.webp
    rm $file
    );
 done
exit