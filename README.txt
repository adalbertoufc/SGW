O SGW é um sistema de gerenciamento WEB bastante útil para quem deseja monitorar e acompanhar o comportamento e as configurações das máquinas presentes na rede. Com uma interface simples e bastante amigável, ele se mostra muito eficaz e prático até  mesmo para usuários leigos. Todo o seu conjunto de ações é implementado em shell script. Assim as ações do SGW são implementadas por dois scripts. Um deles deve estar presente na máquina a ser monitorada e tem como finalidade coletar as informações dessa máquina e gerar uma saída com essas informações quando for executado. O outro script deve estar presente nas máquinas na qual se deseja visualizar as informações, e pode ser chamado de script principal. Ele será responsável pela comunicação e  busca das informações nas máquinas a serem monitoradas. Além disso ele irá  analisar as informações obtidas das máquinas a serem monitoradas e irá determinar como essas informações serão formatadas para serem exibidas no navegador. Esse script principal irá gerar um arquivo HTML com todas as informações devidamente formatadas para serem exibidas no navegador. O código fonte desses scripts estão expostos nos quadros I e II respectivamente, logo abaixo. Logo em seguida será feita uma breve apresentação das principais partes de cada um desses scripts.
===============================================================================================================================================
							Quadro I. Script Principal

     1	#!/bin/bash 
     2	 
     3	if [ "$#" -ne 1 ] 
     4	then 
     5		echo "Usage: $0 <arquivo.conf>" 
     6		exit 1 
     7	fi 
     8	function remove() 
     9	{ 
    10		if [ -f index.html ] 
    11		then 
    12			rm -f index.html 
    13		fi 
    14	} 
    15	function begin_html() 
    16	{ 
    17		echo "<html>" >> index.html 
    18	} 
    19	function begin_head() 
    20	{ 
    21		echo -e "\t<head>" >> index.html 
    22	} 
    23	function tag_title() 
    24	{ 
    25		echo -e "\t\t<title>SGW</title>" >> index.html 
    26	} 
    27	function tag_meta() 
    28	{ 
    29		echo -e "\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />" >> index.html 
    30	} 
    31	function tag_style() 
    32	{ 
    33		echo " 
    34			<style> 
    35				body { margin: 0; } 
    36				div#cabecalho { 
    37	        			background-color: #6633CC; 
    38				        width: auto; 
    39				        height: 110px; 
    40				        padding-top: 20px; 
    41				        padding-bottom: 20px; 
    42					margin-bottom: 50px; 
    43				} 
    44				h1 { 
    45				        text-align: center; 
    46				        font-family: "Comic Sans MS"; 
    47				        color: white; 
    48				        font-size: 50px; 
    49				        font-style: bold; 
    50				} 
    51				p#pmachines { 
    52					color: white; 
    53					font-family: "Comic Sans MS"; 
    54					font-style: bold; 
    55				} 
    56				p#pinfo { 
    57					color: blue; 
    58					family-font: "Comic Sans MS"; 
    59					font-size: 20px; 
    60					font-style: bold; 
    61				} 
    62				p#pstatus { 
    63					color: blue; 
    64	                                family-font: "Comic Sans MS"; 
    65	                                font-size: 20px; 
    66	                                font-style: bold; 
    67				} 
    68				div#machines { 
    69					text-align: center; 
    70					background-color: #6633CC; 
    71					width: 700px; 
    72					height: 35px; 
    73					padding-top: 3px; 
    74					padding-bottom: 3px; 
    75					margin: auto; 
    76					margin-bottom: 5px; 
    77				} 
    78				div#content { 
    79					width: auto; 
    80					clear: both; 
    81				} 
    82				div#info { 
    83					width: 700px; 
    84					height: 90px; 
    85					padding-top: 0px; 
    86					padding-bottom: 20px; 
    87					margin: auto; 
    88					margin-bottom: 10px; 
    89				} 
    90				div#infoText { 
    91	                                width: 540px; 
    92	                                height: 110px; 
    93	                                padding-left: 20px; 
    94	                                padding-right: 20px; 
    95	                                float: left; 
    96	                        } 
    97	                        div#infoStatus { 
    98	                                width: 60px; 
    99	                                height: 110px; 
   100	                                padding-left: 10px; 
   101	                                padding-right: 10px; 
   102	                                float: right; 
   103				} 
   104				p#erro { 
   105					text-align: center; 
   106					family-font: "Helvetica"; 
   107					font-size: 20px; 
   108					color: red; 
   109				} 
   110				p#less_machine { 
   111					text-align: center; 
   112	                                family-font: "Helvetica"; 
   113	                                font-size: 20px; 
   114	                                color: red; 
   115				} 
   116			</style> 
   117			" >> index.html 
   118	} 
   119	function end_head() 
   120	{ 
   121		echo -e "\t</head>" >> index.html 
   122	} 
   123	function begin_body() 
   124	{ 
   125		echo -e "\t<body>" >> index.html 
   126	} 
   127	function div_header() 
   128	{ 
   129		echo -e "\t\t<div id="cabecalho"><h1>SGW</h1></div>" >> index.html 
   130	} 
   131	function begin_content() 
   132	{ 
   133	        echo -e "\t\t<div id="content">" >> index.html 
   134	} 
   135	function find_info() 
   136	{ 
   137		res=$(ssh `grep "$1" ips.conf | tr [:blank:] '@'` './coleta_info.sh') 
   138		echo "$res" 
   139	} 
   140	function verify_load() 
   141	{ 
   142		LOAD=`cut -f1 -d " " <<< "$2"` 
   143		CORES=`echo "scale=2; $1 / 2" | bc` 
   144	 
   145		if [[ "$CORES" =~ \.[0-9]+ ]] 
   146		then 
   147			CORES=`echo "0$CORES"` 
   148		fi 
   149	 
   150		if [ `echo "$LOAD <= $CORES" | bc` -eq 1 ] 
   151		then 
   152			echo "1" 
   153		elif [ `echo "($LOAD > $CORES) && ($LOAD <= $1)" | bc` -eq 1 ] 
   154		then 
   155			echo "2" 
   156		else 
   157			echo "3" 
   158		fi 
   159	} 
   160	function isON() 
   161	{ 
   162		LIGADAS=() 
   163		for mac in `cat "$1"` 
   164		do 
   165		       	if ping -c3 "$mac" > /dev/null 2> /dev/null 
   166		      	then 
   167		             	LIGADAS+=("$mac") 
   168	        	fi 
   169		done 
   170		echo ${LIGADAS[@]} 
   171	} 
   172	function div_machines() 
   173	{ 
   174		vet=(`isON <(awk '{print $2}' $1)`) 
   175		if [ "${#vet[@]}" -gt 0 ] 
   176		then 
   177			for machine in "${vet[@]}" 
   178			do 
   179				if ssh `grep "$machine" ips.conf | tr [:blank:] '@'` './coleta_info.sh' > /dev/null 2> /dev/null 
   180				then 
   181					informs=`find_info "$machine"` 
   182					model=`cut -f1 -d ":" <<< "$informs"` 
   183					cores=`cut -f2 -d ":" <<< "$informs"` 
   184					memory=`cut -f3 -d ":" <<< "$informs"` 
   185					load=`cut -f4 -d ":" <<< "$informs"` 
   186	 
   187					out=`verify_load "$cores" "$load"` 
   188	 
   189					if [ "$out" -eq 1 ] 
   190					then 
   191						image='<img src="status/carga-baixa.png" width="40" height="40" alt="Carga Baixa" title="Carga Baixa" />' 
   192					elif [ "$out" -eq 2 ] 
   193					then 
   194						image='<img src="status/carga-pxlimite.png" width="40" height="40" alt="Carga Prox. ou no Limite" title="Carga Intermediária" />' 
   195					else 
   196						image='<img src="status/sobrecarregado.png" width="40" height="40" alt="Sobrecarregado" title="Sobrecarregado" />' 
   197					fi 
   198	 
   199					echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html 
   200					echo -e " 
   201					<div id="info"> 
   202						<div id="infoText"> 
   203							<p id="pinfo"> 
   204								Modelo CPU: "$model" <br> 
   205								Qtd. de Núcleos: "$cores" <br> 
   206								Memória RAM: "$memory" <br> 
   207								Carga Atual: "$load" <br> 
   208							</p> 
   209						</div> 
   210						<div id="infoStatus"> 
   211							<p id="pstatus">Status: </p> 
   212							"$image" 
   213						</div> 
   214					</div>" >> index.html 
   215				else 
   216					echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html 
   217					echo "<p id="erro"> Verifique se o ssh esta instalado ou o script esta na maquina</p>" >> index.html 
   218				fi 
   219			done 
   220		else 
   221			echo -e "\t\t<p id="less_machine">Nenhuma maquina disponivel para ser exibida no momento</p>" >> index.html 
   222		fi 
   223	} 
   224	function end_content() 
   225	{ 
   226		echo -e "\t\t</div>" >> index.html 
   227	} 
   228	function end_body() 
   229	{ 
   230		echo -e "\t</body>" >> index.html 
   231	} 
   232	function end_html() 
   233	{ 
   234		echo "</html>" >> index.html 
   235	} 
   236	remove 
   237	begin_html 
   238	begin_head 
   239	tag_title 
   240	tag_meta 
   241	tag_style 
   242	end_head 
   243	begin_body 
   244	div_header 
   245	begin_content 
   246	div_machines "$1" 
   247	end_content 
   248	end_body 
   249	end_html

===============================================================================================================================================

	Analisando o quadro I, percebe-se a existência de várias funções responsáveis pela formação do arquivo HTML que irá permitir a visualização das informações no navegador. Essas funções podem ser identificadas principalmente entre as linhas 15-30, 119-134 e 224-235.


===============================================================================================================================================
    15	function begin_html() 
    16	{ 
    17		echo "<html>" >> index.html 
    18	} 
    19	function begin_head() 
    20	{ 
    21		echo -e "\t<head>" >> index.html 
    22	} 
    23	function tag_title() 
    24	{ 
    25		echo -e "\t\t<title>SGW</title>" >> index.html 
    26	} 
    27	function tag_meta() 
    28	{ 
    29		echo -e "\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />" >> index.html 
    30	} 

===============================================================================================================================================

   119	function end_head() 
   120	{ 
   121		echo -e "\t</head>" >> index.html 
   122	} 
   123	function begin_body() 
   124	{ 
   125		echo -e "\t<body>" >> index.html 
   126	} 
   127	function div_header() 
   128	{ 
   129		echo -e "\t\t<div id="cabecalho"><h1>SGW</h1></div>" >> index.html 
   130	} 
   131	function begin_content() 
   132	{ 
   133	        echo -e "\t\t<div id="content">" >> index.html 
   134	} 

===============================================================================================================================================

   224	function end_content() 
   225	{ 
   226		echo -e "\t\t</div>" >> index.html 
   227	} 
   228	function end_body() 
   229	{ 
   230		echo -e "\t</body>" >> index.html 
   231	} 
   232	function end_html() 
   233	{ 
   234		echo "</html>" >> index.html 
   235	}

===============================================================================================================================================

	Cada uma dessas funções desse intervalo se restringem especificamente a anexar no arquivo index.html uma tag. Por exemplo, a função begin_html irá anexar no arquivo index.html a tag <html> para indicar o início do documento html. Já a função end_html irá anexar no arquivo index.html a tag </html> para indicar o fim do documento html. 

	Entre as linhas 31-118 está o escopo da função tag_style que irá definir o estilo dá página usando CSS. 

===============================================================================================================================================

    31	function tag_style() 
    32	{ 
    33		echo " 
    34			<style> 
    35				body { margin: 0; } 
    36				div#cabecalho { 
    37	        			background-color: #6633CC; 
    38				        width: auto; 
    39				        height: 110px; 
    40				        padding-top: 20px; 
    41				        padding-bottom: 20px; 
    42					margin-bottom: 50px; 
    43				} 
    44				h1 { 
    45				        text-align: center; 
    46				        font-family: "Comic Sans MS"; 
    47				        color: white; 
    48				        font-size: 50px; 
    49				        font-style: bold; 
    50				} 
    51				p#pmachines { 
    52					color: white; 
    53					font-family: "Comic Sans MS"; 
    54					font-style: bold; 
    55				} 
    56				p#pinfo { 
    57					color: blue; 
    58					family-font: "Comic Sans MS"; 
    59					font-size: 20px; 
    60					font-style: bold; 
    61				} 
    62				p#pstatus { 
    63					color: blue; 
    64	                                family-font: "Comic Sans MS"; 
    65	                                font-size: 20px; 
    66	                                font-style: bold; 
    67				} 
    68				div#machines { 
    69					text-align: center; 
    70					background-color: #6633CC; 
    71					width: 700px; 
    72					height: 35px; 
    73					padding-top: 3px; 
    74					padding-bottom: 3px; 
    75					margin: auto; 
    76					margin-bottom: 5px; 
    77				} 
    78				div#content { 
    79					width: auto; 
    80					clear: both; 
    81				} 
    82				div#info { 
    83					width: 700px; 
    84					height: 90px; 
    85					padding-top: 0px; 
    86					padding-bottom: 20px; 
    87					margin: auto; 
    88					margin-bottom: 10px; 
    89				} 
    90				div#infoText { 
    91	                                width: 540px; 
    92	                                height: 110px; 
    93	                                padding-left: 20px; 
    94	                                padding-right: 20px; 
    95	                                float: left; 
    96	                        } 
    97	                        div#infoStatus { 
    98	                                width: 60px; 
    99	                                height: 110px; 
   100	                                padding-left: 10px; 
   101	                                padding-right: 10px; 
   102	                                float: right; 
   103				} 
   104				p#erro { 
   105					text-align: center; 
   106					family-font: "Helvetica"; 
   107					font-size: 20px; 
   108					color: red; 
   109				} 
   110				p#less_machine { 
   111					text-align: center; 
   112	                                family-font: "Helvetica"; 
   113	                                font-size: 20px; 
   114	                                color: red; 
   115				} 
   116			</style> 
   117			" >> index.html 
   118	} 


===============================================================================================================================================

	As funções principais do script que implementam suas funcionalidades específicas se concentram entre as linhas 135-223. Essas funções são: find_info, verify_load, isON e a div_machines.

===============================================================================================================================================

   135	function find_info() 
   136	{ 
   137		res=$(ssh `grep "$1" ips.conf | tr [:blank:] '@'` './coleta_info.sh') 
   138		echo "$res" 
   139	} 
   140	function verify_load() 
   141	{ 
   142		LOAD=`cut -f1 -d " " <<< "$2"` 
   143		CORES=`echo "scale=2; $1 / 2" | bc` 
   144	 
   145		if [[ "$CORES" =~ \.[0-9]+ ]] 
   146		then 
   147			CORES=`echo "0$CORES"` 
   148		fi 
   149	 
   150		if [ `echo "$LOAD <= $CORES" | bc` -eq 1 ] 
   151		then 
   152			echo "1" 
   153		elif [ `echo "($LOAD > $CORES) && ($LOAD <= $1)" | bc` -eq 1 ] 
   154		then 
   155			echo "2" 
   156		else 
   157			echo "3" 
   158		fi 
   159	} 
   160	function isON() 
   161	{ 
   162		LIGADAS=() 
   163		for mac in `cat "$1"` 
   164		do 
   165		       	if ping -c3 "$mac" > /dev/null 2> /dev/null 
   166		      	then 
   167		             	LIGADAS+=("$mac") 
   168	        	fi 
   169		done 
   170		echo ${LIGADAS[@]} 
   171	} 
   172	function div_machines() 
   173	{ 
   174		vet=(`isON <(awk '{print $2}' $1)`) 
   175		if [ "${#vet[@]}" -gt 0 ] 
   176		then 
   177			for machine in "${vet[@]}" 
   178			do 
   179				if ssh `grep "$machine" ips.conf | tr [:blank:] '@'` './coleta_info.sh' > /dev/null 2> /dev/null 
   180				then 
   181					informs=`find_info "$machine"` 
   182					model=`cut -f1 -d ":" <<< "$informs"` 
   183					cores=`cut -f2 -d ":" <<< "$informs"` 
   184					memory=`cut -f3 -d ":" <<< "$informs"` 
   185					load=`cut -f4 -d ":" <<< "$informs"` 
   186	 
   187					out=`verify_load "$cores" "$load"` 
   188	 
   189					if [ "$out" -eq 1 ] 
   190					then 
   191						image='<img src="status/carga-baixa.png" width="40" height="40" alt="Carga Baixa" title="Carga Baixa" />' 
   192					elif [ "$out" -eq 2 ] 
   193					then 
   194						image='<img src="status/carga-pxlimite.png" width="40" height="40" alt="Carga Prox. ou no Limite" title="Carga Intermediária" />' 
   195					else 
   196						image='<img src="status/sobrecarregado.png" width="40" height="40" alt="Sobrecarregado" title="Sobrecarregado" />' 
   197					fi 
   198	 
   199					echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html 
   200					echo -e " 
   201					<div id="info"> 
   202						<div id="infoText"> 
   203							<p id="pinfo"> 
   204								Modelo CPU: "$model" <br> 
   205								Qtd. de Núcleos: "$cores" <br> 
   206								Memória RAM: "$memory" <br> 
   207								Carga Atual: "$load" <br> 
   208							</p> 
   209						</div> 
   210						<div id="infoStatus"> 
   211							<p id="pstatus">Status: </p> 
   212							"$image" 
   213						</div> 
   214					</div>" >> index.html 
   215				else 
   216					echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html 
   217					echo "<p id="erro"> Verifique se o ssh esta instalado ou o script esta na maquina</p>" >> index.html 
   218				fi 
   219			done 
   220		else 
   221			echo -e "\t\t<p id="less_machine">Nenhuma maquina disponivel para ser exibida no momento</p>" >> index.html 
   222		fi 
   223	} 

===============================================================================================================================================

Inicialmente a função div_machines recebe como parâmetro um arquivo que possui todos os usuários e os IPs das máquinas a serem monitoradas. A primeira coisa que essa função irá fazer, será chamar a função isON para verificar quais são as máquinas que estão ligadas. Essa função irá ter como saída um array com todos os IPs das máquinas que estão ligadas em um determinado momento. Em seguida, a função div_machines irá testar se a quantidade de máquinas ligadas é maior que 0. Se o resultado do teste for verdadeiro será testado em seguida se o sshserver esta instalado e o script de coleta das informações estão presentes máquinas a serem monitoradas. Se o resultado desse outro teste também for verdadeiro então a função find_info será chamada recebendo como parâmetro a máquina corrente no laço para que sejam extraídas as informações da mesma. A função irá retornar todas as informações concatenadas por “:” (ponto ponto) e irá guardar essas informações na variável informs. Em seguida o conteúdo da variável informs será fragmentado e todas as informações serão armazenadas em uma variável diferente para cada tipo de informação.  No passo seguinte a função verify_load será chamada recebendo como parâmetro o número de núcleos da CPU e a carga atual (load average) da máquina. Essas informações serão utilizadas para verificar se a máquina está com a carga adequada, intermediária ou sobrecarregada. A função verify_load terá como saída 3 valores possíveis: 1 (indicando que a carga é adequada), 2 (indicando que a carga esta em um nível intermediário) e 3 (indicando que há sobrecarga). Essa saída será guardada na variável out que permitirá definir a imagem de status através de um teste condicional. Assim definido todas as variáveis e suas informações, seus valores serão agregados junto ao HTML para posterior exibição no navegador.


===============================================================================================================================================
					Quadro II. script de coleta de informações nos clientes.
     1	#!/bin/bash 
     2	 
     3	MODELO=`grep '^model name' /proc/cpuinfo | sort | uniq | cut -f2  -d ":"` 
     4	NUM_NUCLEOS=`grep '^processor' /proc/cpuinfo | wc -l` 
     5	MEM_TOTAL=`head -1 /proc/meminfo | egrep -o [0-9]*` 
     6	MEM_EM_GIGA=`echo "scale=2; $MEM_TOTAL / (1024*1024)" | bc` 
     7	CARGA=`cat /proc/loadavg` 
     8	 
     9	if [[ "$MEM_EM_GIGA" =~ \.* ]] 
    10	then 
    11		MEM_EM_GIGA="0$MEM_EM_GIGA GB" 
    12	fi 
    13	echo "$MODELO:$NUM_NUCLEOS:$MEM_EM_GIGA:$CARGA" 

===============================================================================================================================================

Analisando agora o script do quadro II, é possível observar que nas linhas 3-8, há várias variáveis que guardam as saídas de sequências de comandos. Na linha 3 por exemplo, a variável modelo guarda o modelo da máquina monitorada e a linha 4 guarda o numero de núcleos, ambos extraídos do arquivo /proc/cpuinfo. Na linha 5 a variável MEM_TOTAL guarda a quantidade de memória RAM, extraída do arquivo /proc/meminfo e na linha 6 o conteúdo de MEM_TOTAL é transformado em GB e guardado na variável MEM_EM_GIGA. Na linha 7 é armazenado a carga da máquina na variável CARGA. Das linhas 9-12, ocorre uma formatação do conteúdo da variável MEM_EM_GIGA caso ela seja menor que 0 e comece com “.” (ponto), será acrescentado um zero antes do ponto e as letras GB depois do conteúdo de MEM_E_GIGA. Em seguida, o conteúdo de todas as variáveis são concatenados pelo caractere “:” e exibidos na saída padrão.
