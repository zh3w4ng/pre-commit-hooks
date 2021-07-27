#!/bin/bash
################################################################################
# Store this file as .git/hooks/commit-msg in your repository in order to
# enforce checking for proper commit message format before actual commits. You
# may need to make the script executable by 'chmod +x .git/hooks/commit-msg'.
################################################################################
filename="$1"
copy=$(tempfile -p gitco)
cat $filename >> $copy
lineno=0

error() {
    echo  "CHECKIN STOPPED DUE TO INAPPROPRIATE LOG MESSAGE FORMATTING!"
    echo "$1!"
    echo ""
    echo "Original checkin message has been stored in '_gitmsg.saved.txt'"
    mv $copy '_gitmsg.saved.txt'
    exit 1
}

while read -r line
do
    # Ignore comment lines (don't count line number either)
    [[ "$line" =~ ^#.* ]] && continue

    let lineno+=1
    length=${#line}

    # Subject line tests
    if [[ $lineno -eq 1 ]]; then
        [[ $length -gt 60 ]] && error "Limit the subject line to 60 characters"
        [[ ! "$line" =~ ^[A-Z].*$ ]] && error "Capitalise the subject line"
        [[ "$line" == *. ]] && error "Do not end the subject line with a period"
    fi

    # Rules related to the commit message body
    [[ $lineno -eq 2 ]] && [[ -n $line ]] && error "Separate subject from body with a blank line"
    [[ $lineno -gt 1 ]] && [[ $length -gt 72 ]] && error "Wrap the body at 72 characters"
done < "$filename"
rm -f $copy
exit 0
