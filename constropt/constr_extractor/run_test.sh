for t in test/*; do
    if [ -d "$f" ]; then
        # $f is a directory
        continue
    fi
    ruby $t
done