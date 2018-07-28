#!/bin/bash
# Script para enviar de top users do SARG por e-mail
#

function MAIN()
{
	DATA
	
	. /etc/scripts/envia_sarg/variaveis.conf
	. /etc/scripts/envia_sarg/servers.conf
	. /etc/scripts/envia_sarg/emails.conf
	. /etc/scripts/envia_sarg/traducao.conf 
		
	#SEMANAL="Ter" # Teste para executar manualmente
	
	if [ $DIAS == $SEMANAL ];then
	
		echo "" > $CAMINHO_LOG/$ARQ_LOG1 #LIMPA O ARQUIVO
		echo "" > $CAMINHO_LOG/$ARQ_LOG2 #LIMPA O ARQUIVO

		for ((s=1;s<=${#IP[@]};s++));
		do
			CONTA_SARG
			ORDENA_SARG
			ORDENA_RELATORIO
		done
		#ENVIA_EMAIL	# Desativado
	fi
}

function CONTA_SARG()
{
	w=1 #Periodo Sarg, Daily=1
	CAMINHO=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[$w]}

        LOGS_GUARDADOS=`ls $CAMINHO | grep 20 | wc -l`
        v=1

	#----- For do ANO -----#
        #--- Coletando todos os anos existendes nos logs ---#
	for ((i=1;i<=$LOGS_GUARDADOS;i++))
        do
		SARG_ANO[$i]=`ls $CAMINHO | cut -c1-9 | grep 20 | head -n $i | tail -n 1 | cut -c6-9`
	done
	#----- Retirando todos os numeros repetidos do vetor -----#
        SARG_ANO_CONTA[1]=${SARG_ANO[1]}
        k=0	
        for ((i=1;i<=$LOGS_GUARDADOS;i++))
        do
		OK=0
		for ((y=1;y<=${#SARG_ANO_CONTA[@]};y++))
		do
			if [ ${SARG_ANO[$i]} != ${SARG_ANO_CONTA[$y]} ];then
				let OK=$OK+1
			fi
			if [ $OK == ${#SARG_ANO_CONTA[@]} ];then
				let k=$k+1
				SARG_ANO_CONTA[$k]=${SARG_ANO[$i]}
			fi
		done
	done
	#----- Ordenando vetor do MENOR para o MAIOR -----#
	for ((i=1;i<=${#SARG_ANO_CONTA[@]};i++))
	do
		for ((y=1;y<=${#SARG_ANO_CONTA[@]};y++))
		do
			if [ ${SARG_ANO_CONTA[$i]} -lt ${SARG_ANO_CONTA[$y]} ];then
				aux=${SARG_ANO_CONTA[$i]}
				SARG_ANO_CONTA[$i]=${SARG_ANO_CONTA[$y]}
				SARG_ANO_CONTA[$y]=$aux
          		fi
            	done
	done
	#----- For do MES -----#
	for ((a=1;a<=${#SARG_ANO_CONTA[@]};a++))
	do
		#----- Coletando todos os meses existende por do ano do vetor -----#
		LOGS_SARG_MES=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | wc -l`
		for ((i=1;i<=$LOGS_SARG_MES;i++))
		do
			SARG_MES[$i]=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | head -n $i | tail -n 1 | cut -c3-5`
			#echo "mes ${SARG_MES[$i]}" teste
		done
     		#----- Retirando todos os numeros repetidos do vetor -----#
 		SARG_MES_CONTA[1]=${SARG_MES[1]}
 		k=1 #ALTERADO PARA 1 (era 0) TESTE
		for ((i=1;i<=$LOGS_SARG_MES;i++))
		do
			OK=0
 			for ((y=1;y<=${#SARG_MES_CONTA[@]};y++))
			do
				if [ ${SARG_MES[$i]} != ${SARG_MES_CONTA[$y]} ];then
					let OK=$OK+1
				fi
				if [ $OK == ${#SARG_MES_CONTA[@]} ];then
					let k=$k+1
 					SARG_MES_CONTA[$k]=${SARG_MES[$i]}
					    				fi
    			done
		done
  		#----- Convertendo o Mes em numeros -----#
		for ((i=1;i<=${#SARG_MES_CONTA[@]};i++))
 		do 	
			case ${SARG_MES_CONTA[$i]} in
			"Jan")
                		SARG_MES_N[$i]=1
                      		;;
 			"Feb")
         			SARG_MES_N[$i]=2
      				;;
			"Mar")
       				SARG_MES_N[$i]=3
	  			;;
  			"Apr")
         			SARG_MES_N[$i]=4
       				;;
    			"May")
     				SARG_MES_N[$i]=5
           			;;
        		"Jun")
      				SARG_MES_N[$i]=6
   				;;
  			"Jul")
 				SARG_MES_N[$i]=7
 			       	;;
 			"Aug")
  				SARG_MES_N[$i]=8
         			;;
 			"Sep")
   				SARG_MES_N[$i]=9
      				;;
  			"Oct")
    				SARG_MES_N[$i]=10
   				;;
 			"Nov")
         			SARG_MES_N[$i]=11
 				;;
        		"Dec")
         			SARG_MES_N[$i]=12
  				;;
 			*)
           			echo "#### ERRO! MES NAO RECONHECIDO MES: ${SARG_MES_CONTA[$i]} ###" # >> $CAMINHO_LOG/$ARQ_LOG1
        			;;

     			esac
   		done
  		#----- Ordenando o Mes do MENOR para o MAIOR respeitando o ano que esta -----#
     		for ((i=1;i<=${#SARG_MES_CONTA[@]};i++))
     		do
 			for ((y=1;y<=${#SARG_MES_CONTA[@]};y++))
   			do
   				if [ ${SARG_MES_N[$i]} -lt ${SARG_MES_N[$y]} ];then
  					aux=${SARG_MES_N[$i]}
					SARG_MES_N[$i]=${SARG_MES_N[$y]}
					SARG_MES_N[$y]=$aux

 					aux2=${SARG_MES_CONTA[$i]}
 					SARG_MES_CONTA[$i]=${SARG_MES_CONTA[$y]}
 					SARG_MES_CONTA[$y]=$aux2
 				fi
			done
		done
 		#----- for do DIA -----#
 		for ((b=1;b<=${#SARG_MES_CONTA[@]};b++))
 		do
 			#----- Coletando todos os dias existentes-----#
 			#---- Respeitando o ano e mes que pertence ---#
  			LOGS_SARG_DIA=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | grep ${SARG_MES_CONTA[$b]}| wc -l`
 			for ((i=1;i<=$LOGS_SARG_DIA;i++))
       			do
  				SARG_DIA_CONTA[$i]=`ls $CAMINHO | cut -c1-9 | grep ${SARG_ANO_CONTA[$a]} | grep ${SARG_MES_CONTA[$b]} | head -n $i | tail -n 1 | cut -c1-2`
      				#---- Guardando todos os logs do sarg ordenado em um novo vetor -----#
    				SARG_DATA[$v]=${SARG_DIA_CONTA[$i]}${SARG_MES_CONTA[$b]}${SARG_ANO_CONTA[$a]}
  				let v=$v+1
			done
        	done
 	done
 	        
	# Ordenando logs do sarg do mais novo para o mais antigo
	e=0
	for ((i=${#SARG_DATA[@]};i>0;i--))
	do
        	let e=$e+1
		SARG_DATA_ORD[$e]=${SARG_DATA[$i]}
	done

}

function ORDENA_SARG()
{
	## Caso for adicionar funcao de delimitar dias da semana adicionar aqui! ###

	### PODE APRESENTAR PROBLEMA QUANDO EXISTIR DUAS DATAS IGUAIS NO INICIO DA PASTA ###
	for ((i=1;i<=${#SARG_DATA[@]};i++))
	do
        	PASTA_SARG[$i]=`ls $CAMINHO | grep "${SARG_DATA_ORD[$i]}-" | head -n 1` 
	done
}

function ORDENA_RELATORIO()
{
	for ((i1=1;i1<=$N_DIAS;i1++))
	do	
		# Transforma o index em uma matriz
		# Coleta o ultimo numero da tabela antes do primeiro usuario
		CAMINHO_RAIZ=$CAMINHO_SARG_DADOS/$DIR_SARG${SITE[$s]}/${PERIODO[1]}/${PASTA_SARG[$i1]}
			
		N1=`cat -n $CAMINHO_RAIZ/$ARQ_INDEX | grep thead | head -n 1 | cut -c4-6`

		for ((i2=1;i2<=$N_USERS;i2++))
		do       
			# Somando numero +1 para saber contador do usuario
    	    		N1=`echo "$N1+1" | bc`

			# Mostrando primeiro usuario
       	 		#USER=`cat -n $CAMINHO_RAIZ/$ARQ_INDEX | grep " $N1" | head -n 1 | cut -d '<' -f 14 | cut -d '>' -f 2` # Coleta o IP dos host
			USER=`cat -n $CAMINHO_RAIZ/$ARQ_INDEX | grep " $N1" | head -n 1 | cut -d '<' -f 6 | cut -d '/' -f 1 | cut -d '=' -f 2 | cut -c2-20`

       			BYTES1=`cat -n $CAMINHO_RAIZ/$ARQ_INDEX | grep " $N1" | head -n 1 | cut -d '<' -f 19 | cut -d '>' -f 2`
			
			# Remover virgula dos bytes
			BYTES1_OK=`echo $BYTES1 | tr -d ','`
        		      		 
			USER_DIR=$USER/$USER.html
			TRADUZ_USER
			
			echo -e "${SARG_DATA_ORD[$i1]};${SITE[$s]};$BYTES1_OK;$USER;TOTAL" >> $CAMINHO_LOG/$ARQ_LOG1

			CAMINHO_USER=$CAMINHO_RAIZ/$USER_DIR
			N2=`cat -n $CAMINHO_USER | grep thead | head -n 1 | cut -c4-6`
		
			for ((i3=1;i3<=$N_URL;i3++))
			do
    	    			N2=`echo "$N2+1" | bc`
				
				URL=`cat -n $CAMINHO_USER | grep " $N2" | head -n 1 | cut -d '<' -f 9 | cut -d '>' -f 2` 
				#echo "cat -n $CAMINHO_USER | grep " $N2" | head -n 1 | cut -d '<' -f 9 | cut -d '>' -f 2" #Teste
				#echo "URL; $URL" #Teste
				BYTES2=`cat -n $CAMINHO_USER | grep " $N2" | head -n 1 | cut -d '<' -f 14 | cut -d '>' -f 2`	
				#echo "cat -n $CAMINHO_USER | grep " $N2" | head -n 1 | cut -d '<' -f 14 | cut -d '>' -f 2" #Teste
				#echo "BYTES $BYTES2" #Teste
				BYTES2_OK=`echo $BYTES2 | tr -d ','`
				
		 		echo -e "${SARG_DATA_ORD[$i1]};${SITE[$s]};$BYTES2_OK;$USER;$URL" >> $CAMINHO_LOG/$ARQ_LOG1
			done
		done
		T1=`cat -n $CAMINHO_RAIZ/$ARQ_TOPSITES | grep thead | head -n 1 | cut -c4-6`
          
		for ((t1=1;t1<=$N_TSITES;t1++))
        	do
                	T1=`echo "$T1+1" | bc`

                	SITES=`cat -n $CAMINHO_RAIZ/$ARQ_TOPSITES | grep " $T1" | head -n 1 | cut -d '<' -f 6 | cut -d '>' -f 2`
               	      	BYTES_SITE1=`cat -n $CAMINHO_RAIZ/$ARQ_TOPSITES | grep " $T1" | head -n 1 | cut -d '<' -f 11 | cut -d '>' -f 2`

             		BYTES_SITE1_OK=`echo $BYTES_SITE1 | tr -d ','`
                	echo -e "${SARG_DATA_ORD[$i1]};${SITE[$s]};$BYTES_SITE1_OK;$SITES" >> $CAMINHO_LOG/$ARQ_LOG2
       		done
	done
}

function TRADUZ_USER()
{
	for ((h=1;h<=${#HOST[@]};h++))
	do
		if [ $USER == ${HOST[$h]} ];then
			USER=${TRADUCAO[$h]}
		fi		
	done
}

function ENVIA_EMAIL()
{
	for ((e=1; e<=${#DESTINATARIO[@]}; e++));
        do
                $ESOFTWARE $REMETENDE ${DESTINATARIO[$e]} < $CAMINHO_LOG/$ARQ_LOG
        done
}

function DATA()
{
	DATA=`date "+%y-%m-%d"` > /dev/null # Data yy-mm-dd
	HORA=`date "+%H:%M:%S"` > /dev/null # Hora hh-mm-ss
	DIAM=`date "+%d"` > /dev/null # Dia em numero dd
	DIAS=`date "+%a"` > /dev/null # Dia da semana abreviado Sab, Dom, Seg.
	 MES=`date "+%m"` > /dev/null # Mes em numero mm
}

MAIN
exit;
