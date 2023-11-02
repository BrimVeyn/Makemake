while [ $# == 0 ]; do
  echo "usage : ./makefile_generator.sh [-d run default] [-n program_name] [-L library directory] [-l library name] [-h headers file directory] <args .c files>\n"
  echo "-n default : test\n"
  echo "-L default : ./library\n"
  echo "-l default : *.a files in ./library/ dir\n"
  echo "-h default : ./include\n"
  echo "<args> default : *.c in current dir\n"
  echo "the created Makefile will have the following rules : all clean fclean re\n"
  echo "Default mode : execute every parameters's default"
  echo "\033[35mWould you like to run program's default mode ? [y/n]\033[0m"
  read answer
  if [ $answer == "y" ]; then
    break 
  elif [ $answer == "n" ]; then
    exit
  fi
done

rm Makefile 2> /dev/null && touch Makefile

program_name="test"

while [ $1 ]
do
  if [ $# -eq 1 ] && [[ $1 == "-d" ]]; then
    break
  fi
  if [ -f $1 ] && [[ $1  == *.c ]]; then
    src_list+="$1 "
  elif [ $1 == "-n" ]; then
    shift
    program_name=$1
  elif [ $1 == "-l" ]; then
    shift
    lsrc=$1
  elif [ $1 == "-L" ]; then
    shift
    ldsrc=$1/
  elif [ $1 == "-h" ]; then
    shift
    hsrc=$1
  fi
  shift
done

if [[ $src_list == "" ]]; then
  src_list=$(echo *.c)
fi
if [ -d ./include ] && [[ $hsrc == "" ]]; then
  hsrc="./include"
fi
if [ -d ./library ] && [[ $ldsrc == "" ]]; then
  ldsrc="./library/"
  lsrc=$(cd ./library/ && echo *.a)
fi

echo "CC = cc" >> Makefile
echo "CFLAGS = -Wall -Werror -Wextra" >> Makefile 
echo "TARGET = $program_name" >> Makefile
echo "SRC = $src_list" >> Makefile

if [ $ldsrc ] && [ $lsrc ] && [[ $hsrc ==  "" ]]; then
  echo "LDSRC = $ldsrc" >> Makefile
  echo "LSRC = $lsrc" >> Makefile
elif [ $ldsrc ] && [ $lsrc ] && [ $hsrc ]; then
  echo "LDSRC = $ldsrc" >> Makefile
  echo "LSRC = $lsrc" >> Makefile
  echo "HSRC = $hsrc" >> Makefile
elif [[ $ldsrc == "" ]] && [[ $lsrc == "" ]] && [ $hsrc ]; then
  echo "HSRC = $hsrc" >> Makefile
fi

echo "OBJ = \$(SRC:.c=.o)\n" >> Makefile

echo "all: \$(TARGET)\n" >> Makefile
echo "\$(TARGET): \$(OBJ)" >> Makefile

if [ $ldsrc ] && [ $lsrc ] && [[ $hsrc == "" ]]; then
  echo "\t\$(CC) \$(CFLAGS) -o \$@ \$(OBJ) \$(LDSRC)\$(LSRC)\n" >> Makefile 
elif [ $ldsrc ] && [ $lsrc ] && [ $hsrc ]; then
  echo "\t\$(CC) \$(CFLAGS) -o \$@ \$(OBJ) \$(LDSRC)\$(LSRC) -I \$(HSRC)\n" >> Makefile 
elif [[ $ldsrc == "" ]] && [[ $lsrc == "" ]] && [ $hsrc ]; then
  echo "\t\$(CC) \$(CFLAGS) -o \$@ \$(OBJ) -I \$(HSRC)\)n" >> Makefile
else
  echo "\t\$(CC) \$(CFLAGS) -o \$@ \$(OBJ)\n" >> Makefile
fi

echo "%.o: %.c" >> Makefile
echo "	\$(CC) \$(CFLAGS) -c $< -o \$@\n" >> Makefile

echo "clean:" >> Makefile
echo "	rm -f \$(OBJ)\n" >> Makefile

echo "fclean: clean" >> Makefile
echo "	rm -f \$(TARGET)\n" >> Makefile

echo "re: fclean all\n" >> Makefile

echo ".PHONY: all clean fclean re" >> Makefile

