# .env file reading
if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi