#!/bin/bash

#-------------------------------------------------------
# Paste from developer.amazon.com below
#-------------------------------------------------------

# This is the name given to your device or mobile app in the Amazon developer portal. To look this up, navigate to https://developer.amazon.com/edw/home.html. It may be labeled Device Type ID.
ProductID=YOUR_PRODUCT_ID_HERE

# Retrieve your client ID from the web settings tab within the developer console: https://developer.amazon.com/edw/home.html
ClientID=YOUR_CLIENT_ID_HERE

# Retrieve your client secret from the web settings tab within the developer console: https://developer.amazon.com/edw/home.html
ClientSecret=YOUR_CLIENT_SECRET_HERE

#-------------------------------------------------------
# No need to change anything below this...
#-------------------------------------------------------

#-------------------------------------------------------
# Pre-populated for testing. Feel free to change.
#-------------------------------------------------------

# Your Country. Must be 2 characters!
Country='US'
# Your state. Must be 2 or more characters.
State='WA'
# Your city. Cannot be blank.
City='SEATTLE'
# Your organization name/company name. Cannot be blank.
Organization='AVS_USER'
# Your device serial number. Cannot be blank, but can be any combination of characters.
DeviceSerialNumber='1xxxxxxxxxx'
# Your KeyStorePassword. We recommend leaving this blank for testing.
KeyStorePassword=''

#-------------------------------------------------------
# Function to parse user's input.
#-------------------------------------------------------
# Arguments are: Yes-Enabled No-Enabled Quit-Enabled
YES_ANSWER=1
NO_ANSWER=2
QUIT_ANSWER=3
parse_user_input()
{
  if [ "$1" = "0" ] && [ "$2" = "0" ] && [ "$3" = "0" ]; then
    return
  fi
  while [ true ]; do
    Options="["
    if [ "$1" = "1" ]; then
      Options="${Options}y"
      if [ "$2" = "1" ] || [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$2" = "1" ]; then
      Options="${Options}n"
      if [ "$3" = "1" ]; then
        Options="$Options/"
      fi
    fi
    if [ "$3" = "1" ]; then
      Options="${Options}quit"
    fi
    Options="$Options]"
    read -p "$Options >> " USER_RESPONSE
    USER_RESPONSE=$(echo $USER_RESPONSE | awk '{print tolower($0)}')
    if [ "$USER_RESPONSE" = "y" ] && [ "$1" = "1" ]; then
      return $YES_ANSWER
    else
      if [ "$USER_RESPONSE" = "n" ] && [ "$2" = "1" ]; then
        return $NO_ANSWER
      else
        if [ "$USER_RESPONSE" = "quit" ] && [ "$3" = "1" ]; then
          printf "\nGoodbye.\n\n"
          exit
        fi
      fi
    fi
    printf "Please enter a valid response.\n"
  done
}

#-------------------------------------------------------
# Function to retrieve user account credentials
#-------------------------------------------------------
# Argument is: the expected length of user input
Credential=""
get_credential()
{
  Credential=""
  read -p ">> " Credential
  while [ "${#Credential}" -lt "$1" ]; do
    echo "Input has invalid length."
    echo "Please try again."
    read -p ">> " Credential
  done
}

#-------------------------------------------------------
# Function to confirm user credentials.
#-------------------------------------------------------
check_credentials()
{
  clear
  echo "======AVS + Ubuntu User Credentials======"
  echo ""
  echo ""
  if [ "${#ProductID}" -eq 0 ] || [ "${#ClientID}" -eq 0 ] || [ "${#ClientSecret}" -eq 0 ]; then
    echo "At least one of the needed credentials (ProductID, ClientID or ClientSecret) is missing."
    echo ""
    echo ""
    echo "These values can be found here https://developer.amazon.com/edw/home.html, fix this now?"
    echo ""
    echo ""
    parse_user_input 1 0 1
  fi

  # Print out of variables and validate user inputs
  if [ "${#ProductID}" -ge 1 ] && [ "${#ClientID}" -ge 15 ] && [ "${#ClientSecret}" -ge 15 ]; then
    echo "ProductID >> $ProductID"
    echo "ClientID >> $ClientID"
    echo "ClientSecret >> $ClientSecret"
    echo ""
    echo ""
    echo "Is this information correct?"
    echo ""
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$YES_ANSWER" ]; then
      return
    fi
  fi

  clear
  # Check ProductID
  NeedUpdate=0
  echo ""
  if [ "${#ProductID}" -eq 0 ]; then
    echo "Your ProductID is not set"
    NeedUpdate=1
  else
    echo "Your ProductID is set to: $ProductID."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "This value should match your ProductID (or Device Type ID) entered at https://developer.amazon.com/edw/home.html."
    echo "The information is located under Device Type Info"
    echo "E.g.: RaspberryPi3"
    get_credential 1
    ProductID=$Credential
  fi

  echo "-------------------------------"
  echo "ProductID is set to >> $ProductID"
  echo "-------------------------------"

  # Check ClientID
  NeedUpdate=0
  echo ""
  if [ "${#ClientID}" -eq 0 ]; then
    echo "Your ClientID is not set"
    NeedUpdate=1
  else
    echo "Your ClientID is set to: $ClientID."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "Please enter your ClientID."
    echo "This value should match the information at https://developer.amazon.com/edw/home.html."
    echo "The information is located under the 'Security Profile' tab."
    echo "E.g.: amzn1.application-oa2-client.xxxxxxxx"
    get_credential 28
    ClientID=$Credential
  fi

  echo "-------------------------------"
  echo "ClientID is set to >> $ClientID"
  echo "-------------------------------"

  # Check ClientSecret
  NeedUpdate=0
  echo ""
  if [ "${#ClientSecret}" -eq 0 ]; then
    echo "Your ClientSecret is not set"
    NeedUpdate=1
  else
    echo "Your ClientSecret is set to: $ClientSecret."
    echo "Is this information correct?"
    echo ""
    parse_user_input 1 1 0
    USER_RESPONSE=$?
    if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
      NeedUpdate=1
    fi
  fi
  if [ $NeedUpdate -eq 1 ]; then
    echo ""
    echo "Please enter your ClientSecret."
    echo "This value should match the information at https://developer.amazon.com/edw/home.html."
    echo "The information is located under the 'Security Profile' tab."
    echo "E.g.: fxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa"
    get_credential 20
    ClientSecret=$Credential
  fi

  echo "-------------------------------"
  echo "ClientSecret is set to >> $ClientSecret"
  echo "-------------------------------"

  check_credentials
}

#-------------------------------------------------------
# Inserts user-provided values into a template file
#-------------------------------------------------------
# Arguments are: template_directory, template_name, target_name
use_template()
{
  Template_Loc=$1
  Template_Name=$2
  Target_Name=$3
  while IFS='' read -r line || [[ -n "$line" ]]; do
    while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]]; do
      LHS=${BASH_REMATCH[1]}
      RHS="$(eval echo "\"$LHS\"")"
      line=${line//$LHS/$RHS}
    done
    echo "$line" >> "$Template_Loc/$Target_Name"
  done < "$Template_Loc/$Template_Name"
}

#-------------------------------------------------------
# Script to check if all is good before install script runs
#-------------------------------------------------------
clear
echo "====== AVS + Ubuntu Licenses and Agreement ======"
echo ""
echo ""
echo "This code base is dependent on several external libraries and virtual environments like VLC, NodeJS, npm, Oracle JDK, OpenSSL, & Maven."
echo ""
echo "Please read the document \"Installer_Licenses.txt\" from the sample app repository and the corresponding licenses of the above."
echo ""
echo "Do you agree to the terms and conditions of the necessary software from the third party sources and want to download the necessary software from the third party sources?"
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
parse_user_input 1 0 1

clear
echo "=============== AVS + Ubuntu Installer =========="
echo ""
echo ""
echo "Welcome to the AVS + Ubuntu installer."
echo "If you don't have an Amazon developer account, please register for one"
echo "at https://developer.amazon.com/edw/home.html and follow the"
echo "instructions on github.com to create an AVS device or application."
echo ""
echo ""
echo "======================================================="
echo ""
echo ""
echo "Do you have an Amazon developer account?"
echo ""
echo ""
parse_user_input 1 1 1
USER_RESPONSE=$?
if [ "$USER_RESPONSE" = "$NO_ANSWER" ]; then
  clear
  echo "====== Register for an Amazon Developer Account ======="
  echo ""
  echo ""
  echo "Please register for an Amazon developer account\nat https://developer.amazon.com/edw/home.html before continuing."
  echo ""
  echo ""
  echo "Ready to continue?"
  echo ""
  echo ""
  echo "======================================================="
  echo ""
  echo ""
  parse_user_input 1 0 1
fi


#--------------------------------------------------------------------------------------------
# Checking if script has been updated by the user with ProductID, ClientID, and ClientSecret
#--------------------------------------------------------------------------------------------

if [ "$ProductID" = "YOUR_PRODUCT_ID_HERE" ]; then
  ProductID=""
fi
if [ "$ClientID" = "YOUR_CLIENT_ID_HERE" ]; then
  ClientID=""
fi
if [ "$ClientSecret" = "YOUR_CLIENT_SECRET_HERE" ]; then
  ClientSecret=""
fi

check_credentials


# Preconfigured variables
OS=ubuntu
User=$(id -un)
Group=$(id -gn)
Origin=$(pwd)
Samples_Loc=$Origin/samples
Java_Client_Loc=$Samples_Loc/javaclient
Companion_Service_Loc=$Samples_Loc/companionService

echo ""
echo ""
echo "==============================================="
echo " Making sure we are installing to the right OS"
echo "==============================================="
echo ""
echo ""
echo "=========== Installing Oracle Java8 ==========="
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
chmod +x $Java_Client_Loc/install-java8.sh
cd $Java_Client_Loc && bash ./install-java8.sh
cd $Origin

echo ""
echo ""
echo "==============================="
echo "*******************************"
echo " *** STARTING INSTALLATION ***"
echo "  ** this may take a while **"
echo "   *************************"
echo "   ========================="
echo ""
echo ""

# Install dependencies
echo "========== Update Aptitude ==========="
sudo apt-get update
sudo apt-get upgrade -y

echo "========== Installing Git ============"
sudo apt-get install -y git

cd $Origin

echo "========== Installing VLC and associated Environmental Variables =========="
sudo apt-get install -y vlc vlc-nox vlc-data
#Make sure that the libraries can be found
sudo sh -c "echo \"/usr/lib/vlc\" >> /etc/ld.so.conf.d/vlc_lib.conf"
sudo sh -c "echo \"VLC_PLUGIN_PATH=\"/usr/lib/vlc/plugin\"\" >> /etc/environment"
sudo ldconfig

echo "========== Installing NodeJS =========="
sudo apt-get install -y nodejs npm build-essential
sudo ln -s /usr/bin/nodejs /usr/bin/node
node -v
sudo ldconfig

echo "========== Installing Maven =========="
sudo apt-get install -y maven
mvn -version
sudo ldconfig

echo "========== Installing OpenSSL and Generating Self-Signed Certificates =========="
sudo apt-get install -y openssl
sudo ldconfig

cd $Origin

echo "========== Generating ssl.cnf =========="
if [ -f $Java_Client_Loc/ssl.cnf ]; then
  rm $Java_Client_Loc/ssl.cnf
fi
use_template $Java_Client_Loc template_ssl_cnf ssl.cnf

echo "========== Generating generate.sh =========="
if [ -f $Java_Client_Loc/generate.sh ]; then
  rm $Java_Client_Loc/generate.sh
fi
use_template $Java_Client_Loc template_generate_sh generate.sh

echo "========== Executing generate.sh =========="
chmod +x $Java_Client_Loc/generate.sh
cd $Java_Client_Loc && bash ./generate.sh
cd $Origin

echo "========== Configuring Companion Service =========="
if [ -f $Companion_Service_Loc/config.js ]; then
  rm $Companion_Service_Loc/config.js
fi
use_template $Companion_Service_Loc template_config_js config.js

echo "========== Configuring Java Client =========="
if [ -f $Java_Client_Loc/config.json ]; then
  rm $Java_Client_Loc/config.json
fi
use_template $Java_Client_Loc template_config_json config.json

echo "========== Installing Java Client =========="
if [ -f $Java_Client_Loc/pom.xml ]; then
  rm $Java_Client_Loc/pom.xml
fi
cp $Java_Client_Loc/pom_pi.xml $Java_Client_Loc/pom.xml
cd $Java_Client_Loc && mvn validate && mvn install && cd $Origin

echo "========== Installing Companion Service =========="
cd $Companion_Service_Loc && npm install && cd $Origin

cd $Origin

echo ""
echo '============================='
echo '*****************************'
echo '========= Finished =========='
echo '*****************************'
echo '============================='
echo ""

Number_Terminals=2

echo "To run the demo, do the following in $Number_Terminals seperate terminals:"
echo "Run the companion service: cd $Companion_Service_Loc && npm start"
echo "Run the AVS Java Client: cd $Java_Client_Loc && mvn exec:exec"

