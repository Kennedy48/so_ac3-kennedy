#!/bin/bash



#Cripto moedas esse é script do grupo 3



##Variaveis

jarCrypo='AppCrypo.jar'

version=$((java -version) 2>&1 | awk '/version/ {print $3}') 

repository='https://github.com/Kennedy48/so_ac3-kennedy'

pathRepository='so_ac3-kennedy'

echo "Bem Vindo a Crypo!"

echo ""



#Vefica se já contém o java instalado

verifyJava(){

    echo "Vamos verificar se voce possui o Java instalado"

    echo ""

    

    if [ "$( dpkg --get-selections | grep default-jre | wc -l )" -eq "0" ]

    then
	echo "Você não possui nenhuma versão do Java instalado"

        sleep 2

        echo ""

        installJava


    else

       echo "Você possui a versão ${version} do Java"

        installGit

    fi

}



##Verificando a existencia do repositorio no diretorio

verifyRepository(){

    echo "Verificando contem o repositorio clonado..."

    echo ""

    if [ "$(ls -l | grep ${pathRepository} | wc -l)" -eq "1" ]

    then

        echo "Você já contém o nosso repositorio clonado"

        echo "Atualizando..."

        cd so_ac3-kennedy

        git pull

        verifyDocker

    else 

        echo "Você não contém nosso repositorio clonado"

        echo "Clonando repositorio..."

        sleep 2

        git clone ${repository}

        echo ""

        echo "Repositorio clonado com sucesso!"

        verifyDocker

    fi

}



##Instalando o java 

installJava(){

    echo "Para que tudo funcione perfeitamente precisamos ter o java instalado!"

    echo "Você gostaria de instalar o Java na sua maquina (y/n)?"

    read valueJava

    if [ \"$valueJava\" == \"y\"  ]

    then

        echo "Muito bem! Então vamos instalar o Java."

        sleep 2

        sudo apt install default-jre -y

        installGit

    else

        echo "Para proseguir por favor instale o java"

        exit 0

    fi

}



##Instalar o Git caso não tenha instalado

installGit(){

    echo "Veficando se contem o git na sua maquina..."

    if [ "$(dpkg --get-selections | grep git | wc -l)" > "0" ]

    then

        sleep 2

        echo "Você já possui o git instalado"

        verifyRepository

    else

        sleep 2

        echo "Você não possui o git instalado em sua maquina"

        echo ""

        echo "Você deseja instalar o git em sua maquina (y/n)"

        read input

        if [ \"$input\" == \"y\" ]

        then

            echo "Instalando o git..."

            sleep 2

            sudo apt-get install git-all

            verifyRepository

            if [ $? -eq 0 ]

            then

                echo "Erro ao instalar o git"

                exit 

            fi

        else

            echo "Para continuar instale o git em sua maquina"

            exit

        fi

    fi

}



verifyDocker(){

    echo "Agora vamos verificar se você contem o docker instalado..."

    if [  -x "$(command -v docker)" ]

    then

        echo "Você contem o docker instalado em sua maquina"

        echo "Iniciando o servico Docker..."

        verifyImageDocker
       
    else

        echo "Você não possui o docker instalado em sua maquina"

        echo ""

        echo "Deseja instalar o docker? (y/n)"

        read valueDocker

        if [ \"$valueDocker\" == \"y\" ]

        then

            echo "Instalando docker..."

            sleep 3

            sudo apt install docker.io

            echo "Docker instalado com sucesso"

            sudo systemctl start docker
            sudo systemctl enable docker

            verifyImageDocker
            

        else

            echo "Para continuar instale o docker em sua maquina"

            exit

        fi
   
    fi

}



verifyImageDocker(){

    if [ "$(sudo docker images | grep mysql | wc -l )" -eq "0" ] 

    then

        echo "Você não contém a imagem"

        echo "Instalando imagem mysql..."

        sleep 2

        sudo docker pull mysql:5.7

        sudo docker images

        verifyContainer

    else    

        echo "Você já contém a imagem do mysql"

        verifyContainer

    fi

}



verifyContainer(){

    ##Verificando se está existe

    if [ "$(sudo docker ps -a | grep CrypoConteiner | wc -l)" -eq 1 ] 
    then 

        if [ "$(sudo docker ps -aq -f status=running -f name=CrypoConteiner)" ] 
        then

            echo "Container ligado!"
            runJar

        else        

            ##Verificando se o container contém na lista de parados e existe

            if [ "$(sudo docker ps -aq -f status=exited -f name=CrypoConteiner)" ] 

            then    

                echo "Você já contem o container porém está parado"

                echo "Vamos liga-lo..."

                $dockerId='$(sudo docker ps -aqf name=CrypoConteiner)'

                sudo docker start $dockerId
                runJar            

            fi

        fi
    else

        echo "Container não existe, vamos cria-lo"

        sudo docker run -d -p 3306:3306 --name CrypoConteiner -e "MYSQL_DATABASE=crypodatabase" -e "MYSQL_ROOT_PASSWORD=urubu100" mysql:5.7
	    
	    exit 0

    fi

}




runJar(){

    echo "Iniciando Aplicação..."

    sleep 2

    java -jar AppCrypo.jar

}



verifyJava
