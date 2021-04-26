# prompt modification
PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\w\[\033[00m\]:\[\033[01;35m\]\d \[\033[01;31m\]\t:\[\033[01;30m\]\[\033[01;32m\]$(git branch --show-current)\[\033[01;36m\]@ "

# .env file reading
if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi