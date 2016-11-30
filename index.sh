#!/bin/bash

if [ "$#" -ne 1 ]
then
	echo "Usage: $0 <arquivo.conf>"
	exit 1
fi
function remove()
{
	if [ -f index.html ]
	then
		rm -f index.html
	fi
}
function begin_html()
{
	echo "<html>" >> index.html
}
function begin_head()
{
	echo -e "\t<head>" >> index.html
}
function tag_title()
{
	echo -e "\t\t<title>SGW</title>" >> index.html
}
function tag_meta()
{
	echo -e "\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />" >> index.html
}
function tag_style()
{
	echo "
		<style>
			body { margin: 0; }
			div#cabecalho {
        			background-color: #6633CC;
			        width: auto;
			        height: 110px;
			        padding-top: 20px;
			        padding-bottom: 20px;
				margin-bottom: 50px;
			}
			h1 {
			        text-align: center;
			        font-family: "Comic Sans MS";
			        color: white;
			        font-size: 50px;
			        font-style: bold;
			}
			p#pmachines {
				color: white;
				font-family: "Comic Sans MS";
				font-style: bold;
			}
			p#pinfo {
				color: blue;
				family-font: "Comic Sans MS";
				font-size: 20px;
				font-style: bold;
			}
			p#pstatus {
				color: blue;
                                family-font: "Comic Sans MS";
                                font-size: 20px;
                                font-style: bold;
			}
			div#machines {
				text-align: center;
				background-color: #6633CC;
				width: 700px;
				height: 35px;
				padding-top: 3px;
				padding-bottom: 3px;
				margin: auto;
				margin-bottom: 5px;
			}
			div#content {
				width: auto;
				clear: both;
			}
			div#info {
				width: 700px;
				height: 90px;
				padding-top: 0px;
				padding-bottom: 20px;
				margin: auto;
				margin-bottom: 10px;
			}
			div#infoText {
                                width: 540px;
                                height: 110px;
                                padding-left: 20px;
                                padding-right: 20px;
                                float: left;
                        }
                        div#infoStatus {
                                width: 60px;
                                height: 110px;
                                padding-left: 10px;
                                padding-right: 10px;
                                float: right;
			}
			p#erro {
				text-align: center;
				family-font: "Helvetica";
				font-size: 20px;
				color: red;
			}
			p#less_machine {
				text-align: center;
                                family-font: "Helvetica";
                                font-size: 20px;
                                color: red;
			}
		</style>
		" >> index.html
}
function end_head()
{
	echo -e "\t</head>" >> index.html
}
function begin_body()
{
	echo -e "\t<body>" >> index.html
}
function div_header()
{
	echo -e "\t\t<div id="cabecalho"><h1>SGW</h1></div>" >> index.html
}
function begin_content()
{
        echo -e "\t\t<div id="content">" >> index.html
}
function find_info()
{
	res=$(ssh `grep "$1" ips.conf | tr [:blank:] '@'` './coleta_info.sh')
	echo "$res"
}
function verify_load()
{
	LOAD=`cut -f1 -d " " <<< "$2"`
	CORES=`echo "scale=2; $1 / 2" | bc`

	if [[ "$CORES" =~ \.[0-9]+ ]]
	then
		CORES=`echo "0$CORES"`
	fi

	if [ `echo "$LOAD <= $CORES" | bc` -eq 1 ]
	then
		echo "1"
	elif [ `echo "($LOAD > $CORES) && ($LOAD <= $1)" | bc` -eq 1 ]
	then
		echo "2"
	else
		echo "3"
	fi
}
function isON()
{
	LIGADAS=()
	for mac in `cat "$1"`
	do
	       	if ping -c3 "$mac" > /dev/null 2> /dev/null
	      	then
	             	LIGADAS+=("$mac")
        	fi
	done
	echo ${LIGADAS[@]}
}
function div_machines()
{
	vet=(`isON <(awk '{print $2}' $1)`)
	if [ "${#vet[@]}" -gt 0 ]
	then
		for machine in "${vet[@]}"
		do
			if ssh `grep "$machine" ips.conf | tr [:blank:] '@'` './coleta_info.sh' > /dev/null 2> /dev/null
			then
				informs=`find_info "$machine"`
				model=`cut -f1 -d ":" <<< "$informs"`
				cores=`cut -f2 -d ":" <<< "$informs"`
				memory=`cut -f3 -d ":" <<< "$informs"`
				load=`cut -f4 -d ":" <<< "$informs"`

				out=`verify_load "$cores" "$load"`

				if [ "$out" -eq 1 ]
				then
					image='<img src="status/carga-baixa.png" width="40" height="40" alt="Carga Baixa" title="Carga Baixa" />'
				elif [ "$out" -eq 2 ]
				then
					image='<img src="status/carga-pxlimite.png" width="40" height="40" alt="Carga Prox. ou no Limite" title="Carga Intermediária" />'
				else
					image='<img src="status/sobrecarregado.png" width="40" height="40" alt="Sobrecarregado" title="Sobrecarregado" />'
				fi

				echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html
				echo -e "
				<div id="info">
					<div id="infoText">
						<p id="pinfo">
							Modelo CPU: "$model" <br>
							Qtd. de Núcleos: "$cores" <br>
							Memória RAM: "$memory" <br>
							Carga Atual: "$load" <br>
						</p>
					</div>
					<div id="infoStatus">
						<p id="pstatus">Status: </p>
						"$image"
					</div>
				</div>" >> index.html
			else
				echo -e "\t\t<div id="machines"><p id="pmachines">Máquina: $machine</p></div>" >> index.html
				echo "<p id="erro"> Verifique se o ssh esta instalado ou o script esta na maquina</p>" >> index.html
			fi
		done
	else
		echo -e "\t\t<p id="less_machine">Nenhuma maquina disponivel para ser exibida no momento</p>" >> index.html
	fi
}
function end_content()
{
	echo -e "\t\t</div>" >> index.html
}
function end_body()
{
	echo -e "\t</body>" >> index.html
}
function end_html()
{
	echo "</html>" >> index.html
}
remove
begin_html
begin_head
tag_title
tag_meta
tag_style
end_head
begin_body
div_header
begin_content
div_machines "$1"
end_content
end_body
end_html
