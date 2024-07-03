for file in $(dirname $0)/functions.sh.d/**/*.sh; do
    source "$file"
done

