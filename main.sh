#!/bin/bash
#

sign_up(){
	echo -e "\e[92mSign Up\e[0m"

	# store content of username file as an array to the users variable
	users=(`cat usernames.csv`)	

	# check username length
	valid_name=0 
	while [ $valid_name -eq 0 ]
	do 
		read -p "Enter username: " username

		if ((${#username} < 5))
		then 
			echo -e "\e[91mUsername must have atleast 5 characters!\e[0m"
		else
			valid_name=1
		fi
	done

	# check if username is already exist
	num_users=${#users[@]}
	for((i=0; i < num_users; i++))
	do
		userid=${users[i]}
		if [[ "$username" == "$userid" ]]
		then
			echo
			echo -e "\e[91mUsername is taken! Please choose another username.\e[0m"
			echo
			#call sign_up to start the process again
			sign_up 
		fi
	done

	# check for password length
	valid_pw=0
	while [ $valid_pw -ne 1 ]
	do
		echo "Enter Password: "

		# using option -s (silent) to not show what the user type in the screen 
		read -s password
		
		# checking length of the password
		if ((${#password} < 6))
		then
			echo -e "\e[91mPlease enter atleast 6 character for your password!\e[0m"
		else
			valid_pw=1
		fi
	done
	
	# reconfirm password and store it in according files 
	pass=0
	attempts=4
	while [ $pass -eq 0 -a $attempts -ne 0 ]
	do
		echo "Confirm Password: "
		read -s confirmed_pw
		if [ $confirmed_pw = $password ]
		then
			pass=0
			echo
			echo -e "\e[92mYou have successfully created your Username & Password!\e[0m"
			echo
			echo $username >> usernames.csv
			echo $confirmed_pw >> passwords.csv
			welcome
		else
			attempts=$(($attempts - 1))
			
			if [ $attempts -gt 1 ]
			then
				plural="s"
			else
				plural=""
			fi
			echo -e "\e[91mWrong Password entered! You can try $attempts more time$plural\e[0m"
			if [ $attempts -eq 0 ]
			then 
				echo -e "\e[91mYou reached your maximum limit.\e[0m"
				echo "Please Sign-up again."
				echo
				sign_up
			fi
		fi
	done
}

sign_in() {
	echo -e "\e[92mSign-in\e[0m"
	users=(`cat usernames.csv`)
	num_users=${#users[@]}

	found=0
	attempts=4

	# using while-do loop to keep prompting user enter correct username & passwords  
	while [ $found -eq 0 -a $attempts -ne 0 ]
	do 
		read -p "Enter your username: " username
		# check if the username exist
		for((i=0; i < num_users; i++))
		do
			userid=${users[i]}
			# check if user exist and record the index if exist
			if [[ "$username" == "$userid" ]]
			then
				found=1
				position=$i
			fi
		done
		if [ $found -ne 1 ]
		then
			echo -e "\e[91mUsername doesn't exist.\e[0m"
			attempts=$(($attempts-1))
			if [ $attempts -gt 0 ]
			then
				echo -e "\e[91mPlease try again\e[0m"
				if [ $attempts -gt 1 ]
				then
					plural="s"
				else
					plural=""
				fi
				echo -e "\e[91mYou have $attempts time$plural left.\e[0m"
				echo
			else 
				echo -e "\e[91mYou reach the maximum limit."
				echo "Please sign-up again!\e[0m"
				echo
				welcome
			fi
		fi
	done
			
	passwords=(`cat passwords.csv`)
	attempts=4
	found=0
	while [ $found -eq 0 -a $attempts -ne 0 ]
	do
		echo "Enter your password: " 
		read -s password
		if [ ${passwords[$position]} = $password ] 
		then
			found=1
			echo -e "\e[92mPassword Correct\e[0m"
			echo
			# put start test function
			take_test
		else
			echo -e "\e[91mPassword Incorrect. Please try again!\e[0m"
			attempts=$(($attempts-1))
			if [ $attempts -gt 0 ]
			then
				echo -e "\e[91mYou have $attempts times remaining\e[0m"
			else
				echo -e "\e[91mReach max attempts limits. Sign in again later!\e[0m"
				echo
				welcome
			fi
		fi
	done
	
}

take_test() {

	echo "1. Take quiz!"
	echo "2. Exit."
	echo
	read -p "Enter your choice: " choice
	line=`cat question_bank.txt | wc -l`
	case $choice in
		1)
			# since the each question part contains 5 lines 
			# this will start from 
			for ((i=5;i<=$line;i+=5))
			do
				echo
				head -$i question_bank.txt | tail -5
				echo

				# check if the answer is valid	
				valid=0
				while [ $valid -eq 0 ]
				do
					read -p "Enter the correct answer: " ans
					if [ $ans == "a" ] || [ $ans == "b" ] || [ $ans == "c" ] || [ $ans == "d" ]
					then
						valid=1
						echo "$ans" >> user_answer.txt
					else
						echo -e "\e[91mInvalid answer.\e[0m"
						echo	
					fi
				done
			done
			;;

		2)
			exit
			;;
		*) echo "Please choose the correct option!"
			take_test
			;;
	esac
	#call result function
	result
}

result() {
	echo
	echo "Result"
	c_ans=(`cat correct_answer.txt | cut -d ':' -f1`)
	c_ans1=(`cat correct_answer.txt | cut -d ':' -f2`)
	u_ans=(`tail -5 user_answer.txt`)
	score=0

	num_answers=${#c_ans[@]}
	for ((i=0; i < num_answers; i++))
	do
		if [ ${c_ans[i]} =  ${u_ans[i]} ]
		then
			echo -e "Q$(($i+1)). Your answer is : ${c_ans[i]} (\e[92mCorrect\e[0m)"
			echo "Correct answer is: ${c_ans[i]}. ${c_ans1[i]}"
			echo 
			score=$(($score+1))
		else
			echo -e "Q$(($i+1)). Your answer is: ${u_ans[i]} (\e[91mIncorrect\e[0m)"
			echo "Correct answer is: ${c_ans[i]}. ${c_ans1[i]}"
			echo
		fi
	done
	echo "Your total score: $score"
	echo 
	exit
}

welcome(){
	echo -e "\e[94m1. Sign up\e[0m"
	echo -e "\e[94m2. Sign in\e[0m"
	echo -e "\e[94m3. Exit\e[0m"
	echo 
	#prompt & read the user's choosen option from the keyboard
	read -p "Please choose option : " choice
	case $choice in 
		1) echo
			sign_up
			;;
		2) echo
			sign_in
			;;
		3) echo
			exit
			;;
		*) echo -e "\e[91mPlease choose the correct option!\e[0m"
			welcome
			;;
	esac
}

welcome

