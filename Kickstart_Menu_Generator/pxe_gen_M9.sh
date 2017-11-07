#!/bin/bash

#Определяемся с директорией, в которую выкачан GIT
GPATH=$(echo ~+/$0 | sed "s/${0}//g")
#GPATH=$(echo ~+/$0 | sed "s/\.git\/hooks\/${0}//g")
echo $GPATH
#Определяем через переменную директорию с M9-kickstarts
MGPATH=${GPATH}M9_kickstarts
#Определяем через переменную директорию с OLD-M9-kickstarts
MGOPATH=${GPATH}M9_kickstarts/Old/
#Перейдем в директорию, для работы с kickstart в ней.
cd $MGPATH
mkdir ../M9_pxe_menu/
#####################################################################
###########################Functions#################################
#####################################################################
#Генерация файла default для pxe menu. 
#Функция m_generate вызывается циклически, генерируя меню вида <<menu begin\n menu title <NAME>\n ...>>
function m_generate () {
cd $MGPATH
counter=100
#В качестве параметра, для функции последовательно в цикле while передаются имена директорий. Из них делаются menu <Directory_name>.
echo -e "menu begin\nmenu title $1\nlabel ..\nmenu exit\n" >> ${counter}_menu
}
#Функция l_generate вызывается циклически, генерируя меню вида <<LABEL <LABEL_NAME>...>>

function l_generate () {
cd $MGPATH
#Парсим имя kickstart-файла на предмет наличия точек или знаков плюс в имени (custom/non-custom files)
main_name=$(echo $label | sed -r 's/(\.|\+).*//g')

basename $label | egrep '(custom|netboot)' 
#Куча разветвлений, генерирующих разное наполнение default файла, в зависимости от того, custom'ный кикстарт или нет.
# *_alter_append - переменная инициализируется ниже, проверят наличие в кастомах того или иного параметра (их может быть 1, 2 или 3)
if [ $? -eq 0 ];
  then
        echo -e "LABEL $label\nMENU LABEL $label" >> ${counter}_menu
        echo -e "kernel /images/$2/$alter_kernel" >> ${counter}_menu
          if [ $ksid -lt 1 ];
                then
                  if [ $r_alter_append -eq 1 ];
                        then
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        else
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append\nipappend 2\n" >> ${counter}_menu
                        fi
                else
                if [ $r_alter_append -eq 1 ];
                        then
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        else
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append ks=http://10.0.0.2/cblr/svc/op/ks/profile/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        fi
                fi
  else
        echo -e "LABEL $label\nMENU LABEL $label" >> ${counter}_menu
        echo -e "kernel /images/$2/$d_kernel" >> ${counter}_menu
        echo -e "append initrd=/images/$2/$d_initrd $d_append/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
  fi
}
#То же, что и l_generate() но для директории Old (kickstarts for Centos5/6.4/etc useless trash)
function ol_generate () {
cd $MGPATH
main_name=$(echo $label | sed -r 's/(\.|\+).*//g')

basename $label | egrep '(custom|netboot)' 
if [ $? -eq 0 ];
  then
        echo -e "LABEL $label\nMENU LABEL $label" >> ${counter}_menu
        echo -e "kernel /images/$2/$alter_kernel" >> ${counter}_menu
          if [ $ksid -lt 1 ];
                then
                  if [ $r_alter_append -eq 1 ];
                        then
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append/Old/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        else
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append\nipappend 2\n" >> ${counter}_menu
                        fi
                else
                if [ $r_alter_append -eq 1 ];
                        then
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append/Old/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        else
                          echo -e "append initrd=/images/$2/$alter_initrd $alter_append ks=http://10.0.0.2/cblr/svc/op/ks/profile/Old/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
                        fi
                fi
  else
        echo -e "LABEL $label\nMENU LABEL $label" >> ${counter}_menu
        echo -e "kernel /images/$2/$d_kernel" >> ${counter}_menu
        echo -e "append initrd=/images/$2/$d_initrd $d_append/Old/$2/$3/$1\nipappend 2\n" >> ${counter}_menu
  fi
}

#Статичная функция для генерации rescueCD-menu
function rsq_generate() {
cd $MGPATH
echo -e "DEFAULT menu\nPROMPT 0\nMENU TITLE PXE MENU by Sputnik-sysadms\nTIMEOUT 6000\nTOTALTIMEOUT 6000\nONTIMEOUT local\n\n" >> st_menu
echo -e "menu begin\nmenu title LiveCD-SystemRescueCD-2-8-0\nlabel ..\nmenu exit\n\nLABEL kernel-x86_64\nkernel /images/systemrescuecd-x86-2.8.0/rescue64\nappend initrd=/images/systemrescuecd-x86-2.8.0/initram.igz ksdevice=bootif lang= netboot=http://10.0.0.2/cblr/svc/op/ks/profile/systemrescuecd-x86-2.8.0/sysrcd.dat dodhcp text\nipappend 2\nmenu end\n" >> st_menu
echo -e "menu begin\nmenu title Diags\nlabel ..\nmenu exit\n\nLABEL memtest86+-4.10\nkernel /images/memtest86+-4.10\n\nLABEL HDT\nkernel /images/hdt.c32\nappend pciids=/images/pci.ids\n\nMENU end\n" >> st_menu
}
####################################################################
############################Main program############################
####################################################################

#Генерация заголовка pxe_menu, а так же resqueCD.
rsq_generate
#Счетчик для последовательного обхода директорий на первом уровне цикла. Здесь в $menu передаются имена директорий CentOS-6.5/CentOS-7/Old/etc.
menu_counter=1
#Скрипт работает только если глубина вложенности директорий одинакова. По этой причине, из цикла обхода исключается Old. images исключается, т.к. реализован в rsq_generate()-функции.
while [ $menu_counter -le `ls -l | grep drwx | grep -v images | grep -v Old | wc -l` ]; do
	menu=$(ls -l | grep drwx | grep -v images | grep -v Old | head -n$menu_counter | tail -n1 | awk {'print $NF'})
	#Передача параметра $menu в функцию m_generate для начала отрисовки pxe_menu.
	m_generate "$menu"
	#Подготовка для перехода во внутренний цикл. Необходимо сделать cd $menu, поскольку в m_generate() происходит переход в директорию выше.
	cd $menu
	#Счетчик для последовательного обхода директорий на втором уровне цикла. Здесь в $smenu (submenu) передаются имена директорий Bare-Metal-{1..3}U/Clear/VM/etc.
	smenu_counter=1
		while [ $smenu_counter -le `ls | wc -l` ]; do
			submenu=$(ls | head -n$smenu_counter | tail -n1)
			#Передача параметра $submenu в функцию m_generate для продолжения отрисовки pxe_menu. Данный параметр будет рисоваться <<внутрь>> уже ранее отрисованного по $menu из верхнего цикла.
			#До тех пор, пока цикл не завершится, все $submenu будет отрисовываться внутри menu текущей итерации $menu.
			m_generate "$submenu"
			#Подготовка для перехода во вложенный, последний цикл. cd $menu/$submenu выполняется поскольку в m_genereate() был переход на две директории выше.
			cd $menu/$submenu
			#Счетчик для последовательного обхода файлов на последнем уровне цикла. Здесь в $label передаются имена kickstart-файлов, по которым отрисовываются LABEL.
			label_counter=1
				while [ $label_counter -le `ls | wc -l` ]; do
					label=$(ls | head -n$label_counter | tail -n1)
					#Я не помню для чего нужен ksid, но оставьте как есть.
				        ksid=$(cat $label | egrep -woc '(install|url)')
                                        basename $label | egrep '(custom|netboot)' 
					#Если имя kickstart-файла содержит custom/netboot - инициализируются флаги, проверяющие вхождение недефолтных конфигов: alter kernel, alter initrd, 
					#alter append. Если флаг есть - использует его. Если нет - читает "default" kernel/initrd/append из default_label файла в M9_kickstarts-dir
                                          if [ $? -eq 0 ]; then
                                                alter_kernel=$(cat $label | grep 'POINT kernel' | sed 's/\#POINT kernel //g')
                                                 r_alter_kernel=$(echo $alter_kernel | wc -c)
                                                alter_initrd=$(cat $label | grep 'POINT initrd' | sed 's/\#POINT initrd //g')
                                                 r_alter_initrd=$(echo $alter_initrd | wc -c)
                                                alter_append=$(cat $label | grep 'POINT append' | sed 's/\#POINT append //g' | sed 's/ks=http.*//g')
                                                 r_alter_append=$(echo $alter_append | wc -c)
                                                        if [ $r_alter_kernel -eq 1 ]; then
                                                          alter_kernel=$(cat ${MGPATH}/default_label | grep kernel | sed 's/kernel //g')
                                                        fi
                                                        if [ $r_alter_initrd -eq 1 ]; then
                                                          alter_initrd=$(cat ${MGPATH}/default_label | grep initrd.img | sed 's/initrd //g')
                                                        fi
                                                        if [ $r_alter_append -eq 1 ]; then
                                                          alter_append=$(cat ${MGPATH}/default_label | grep append | sed 's/append //g')
                                                        fi
						#Вызов l_generate() с передачей определенных в цикле выше флагов. Вызывается только если в имени kickstart-файла есть вхождение custom/netboot
                                                l_generate "$label" "$menu" "$submenu" "$alter_kernel" "$alter_initrd" "$alter_append" "$r_alter_kernel" "$r_alter_initrd" "$r_alter_append" "$ksid"
                                          else
						#Ветвление для "обыкновенных" кикстартов
                                                d_kernel=$(cat ${MGPATH}/default_label | grep kernel | sed 's/kernel //g')
                                                d_initrd=$(cat ${MGPATH}/default_label | grep initrd.img | sed 's/initrd //g')
                                                d_append=$(cat ${MGPATH}/default_label | grep append | sed 's/append //g')
                                                  r_alter_append=$(echo $d_append | wc -c)
                                                l_generate "$label" "$menu" "$submenu" "$d_kernel" "$d_initrd" "$d_append" "$r_alter_append" "$ksid"
                                          fi	
					cd $menu/$submenu
					((label_counter++))
				done
			#По выходу из цикла генерации LABEL, необходимо закрыть родительское menu строкой <<menu end>>.
			echo -e 'menu end' >> $MGPATH/100_menu
			#По окончании вложенного цикла, возвращаемся в родительскую директорию.
			cd ..
			((smenu_counter++))
		done
		#Как только закончилась генерация (sub)menu, родительское menu закрывается строкой <<menu end>>.
		echo -e 'menu end' >> $MGPATH/100_menu
		cd ..
		((menu_counter++))
done
#Закрываем родительское menu.
echo -e 'menu end' >> $MGPATH/100_menu

###############################################################
###########Current Menu Ready, do Old-menu now################
##############################################################

#Идущий ниже блок практически полностью совпадает с блоком выше. Служит для генерации Old-директории в pxe_boot_menu.
echo -e 'menu begin\nmenu title Old\nlabel ..\nmenu exit\n' >> $MGPATH/100_menu
cd $MGOPATH
menu_counter=1
while [ $menu_counter -le `ls | wc -l` ]; do
	menu=$(ls | head -n$menu_counter | tail -n1)
	m_generate "$menu"
	cd ${MGOPATH}$menu
		smenu_counter=1
		while [ $smenu_counter -le `ls | wc -l` ]; do
			submenu=$(ls | head -n$smenu_counter | tail -n1)
			m_generate "$submenu"
			cd ${MGOPATH}$menu/$submenu
				label_counter=1
				while [ $label_counter -le `ls | wc -l` ]; do
					label=$(ls | head -n$label_counter | tail -n1)
					ksid=$(cat $label | egrep -woc '(install|url)')
                                        basename $label | egrep '(custom|netboot)' 
                                          if [ $? -eq 0 ]; then
                                                alter_kernel=$(cat $label | grep 'POINT kernel' | sed 's/\#POINT kernel //g')
                                                 r_alter_kernel=$(echo $alter_kernel | wc -c)
                                                alter_initrd=$(cat $label | grep 'POINT initrd' | sed 's/\#POINT initrd //g')
                                                 r_alter_initrd=$(echo $alter_initrd | wc -c)
                                                alter_append=$(cat $label | grep 'POINT append' | sed 's/\#POINT append //g' | sed 's/ks=http.*//g')
                                                 r_alter_append=$(echo $alter_append | wc -c)
                                                        if [ $r_alter_kernel -eq 1 ]; then
                                                          alter_kernel=$(cat ${MGPATH}/default_label | grep kernel | sed 's/kernel //g')
                                                        fi
                                                        if [ $r_alter_initrd -eq 1 ]; then
                                                          alter_initrd=$(cat ${MGPATH}/default_label | grep initrd.img | sed 's/initrd //g')
                                                        fi
                                                        if [ $r_alter_append -eq 1 ]; then
                                                          alter_append=$(cat ${MGPATH}/default_label | grep append | sed 's/append //g')
                                                        fi
                                                ol_generate "$label" "$menu" "$submenu" "$alter_kernel" "$alter_initrd" "$alter_append" "$r_alter_kernel" "$r_alter_initrd" "$r_alter_append" "$ksid"
                                          else
                                                d_kernel=$(cat ${MGPATH}/default_label | grep kernel | sed 's/kernel //g')
                                                d_initrd=$(cat ${MGPATH}/default_label | grep initrd.img | sed 's/initrd //g')
                                                d_append=$(cat ${MGPATH}/default_label | grep append | sed 's/append //g')
                                                  r_alter_append=$(echo $d_append | wc -c)
                                                ol_generate "$label" "$menu" "$submenu" "$d_kernel" "$d_initrd" "$d_append" "$r_alter_append" "$ksid"
                                          fi	
					cd ${MGOPATH}$menu/$submenu
                                        ((label_counter++))
                                done
                        echo -e 'menu end' >> $MGPATH/100_menu
                        cd ..
                        ((smenu_counter++))
                done
                echo -e 'menu end' >> $MGPATH/100_menu
                cd ..
                ((menu_counter++))
done
echo -e 'menu end' >> $MGPATH/100_menu


##########################################################################
#################Finally, compacting files in a single####################
##########################################################################

#pxe_boot_menu генерировалось в два разных файла. Сливаем их в один, удаляем временные файлы.
cat $MGPATH/st_menu > $MGPATH/default_menu
cat $MGPATH/100_menu >> $MGPATH/default_menu
rm -rf $MGPATH/100_menu
rm -rf $MGPATH/101_menu
rm -rf $MGPATH/st_menu
#########################################################################

###Add Ubuntu!###
cd $MGPATH
cd ..
#ubuntu=$(ls M9_Ubuntu/ | grep Ubuntu)

#for i in $ubuntu; do
	echo -e "menu begin\nmenu title Ubuntu-Server-14.04 Netinstall\nlabel ..\nmenu exit\n\nLABEL Install Ubuntu-Server-14.04\nkernel images/Ubuntu-Server-14.04/linux\nappend vga=788 initrd=images/Ubuntu-Server-14.04/initrd.gz -- quiet\n" >> $MGPATH/default_menu
#done
echo -e 'menu end\n' >> $MGPATH/default_menu

#pxe_boot_menu-file готов, перемещаем в отведенную для него директорию. Удаляем последний временный файл.
cd $MGPATH
cp $MGPATH/default_menu ../M9_pxe_menu/default 
rm -rf $MGPATH/default_menu
rm -rf ../M9_kickstarts/100_menu

