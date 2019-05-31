include console.inc    

public PopulationGEN, OcenkaPopul, Selection, Skreshiv, Mutation 

.code



;ГЕНЕРАЦИЯ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PopulationGEN proc X:dword, rand:dword

	local numA:dword				; резервируем стек под локальные переменные
	local numM:dword
	
	pusha							; при вызове процедур рекомендуют сохранять все регистры 
									
	mov numA, 48271					; простое число для расчета по Лемеру
	mov numM, 2147483647			; максимальное положительное для расчета по Лемеру
	
	mov edi, dword ptr [rand]		; адрес rand из стека через параметры вызова
	mov esi, dword ptr [X]			; адрес X из стека через параметры вызова
		                            
	mov ecx,0	                    ; цикл (0..4) 5 по количеству X в уравнении
	
generate:	                        	                            
	mov eax, dword ptr [edi]		; инициализация ГПСЧ из глобальной переменной rand
									; Расчет ПСЧ по Лемеру из лабораторной 9.1
	mul numA						; eax=a * X(i-1) (умножаем eax на dword, указанный по адресу в numA=48271)
	div numM						; a * X(i-1) mod m (полученное произведение в eax делим на dword, указанного по адресу в numM=2147483647)
		                            
	mov dword ptr [edi], edx		; сохраняем вычисленое ПСЧ в глобальную переменную rand для поддержания цепочки вызовов ГПСЧ с инициализацией предыдущим значением
	                                
									
	cmp dl,0						; если в последнем байте ПСЧ получен 0, то повторить Лемера (Ведь Иксы строго положительны)
	jz generate	                    
		                            
	mov byte ptr [esi+ecx],dl		; иначе, полученное значение сохраняем как один из Иксов в наш массив X (смещение по массиву через счетчик цикла ECX)
		                            
	inc ecx							
	cmp ecx,5						
	jne generate					; конец тела цикла
		                            
	popa	                        ; восстанавливаем все регистры
	
	ret 8							; восстанавливаем указатель стека
	
PopulationGEN endp




;ОЦЕНКА ОТКЛОНЕНИЯ ОТ D~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OcenkaPopul proc A:dword, X:dword, D:dword  ; Расчёт отклонения от равенства уравнения нулю
			
local SumOfMul:dword				; резервируем стек под локальные переменные

	pusha							; при вызове процедур рекомендуют сохранять все регистры 
	
	mov ecx,0						; инициализируем переменные ( счетчик цикла )
	mov SumOfMul,0					; ( переменная для суммы )
	
	mov edi,dword ptr [X]			; берем переданные через стек адреса массивов X и A 
	mov esi,dword ptr [A]			
	
SummMul:							; цикл от 0 до 5 по количеству X в уравнении
	xor eax,eax						; инициализация eax нулем для однозачности результата умножения  
	mov al,byte ptr [esi+ecx]		; готовим сомножители A[i] и X[i]
	mov bl,byte ptr [edi+ecx]		
	mul bl							; вычисляем A[i]*X[i]
	
	add SumOfMul,eax				; суммируем результаты умножения
	
	inc ecx							 
	cmp ecx,5						
	jne SummMul						; конец тела цикла

	mov edx,dword ptr [D]			; переменная D передавалась в процедуру по значению, поэтому сможем брать ее из стека
	sub SumOfMul,edx				; вычисляем разность ( отклонение от равенства уравения A1*X1+...+A5*X5-D нулю )
	
	popa							; восстанавливаем все регистры
	
	mov eax, SumOfMul				; через eax возвращаем результат, уже после восстановленных регистров, поэтому после выхода из процедуры изменится только eax
	
	ret 12							; восстанавливаем указатель стека
	
OcenkaPopul endp




;СЕЛЕКЦИЯ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Selection proc Res: dword, X:dword, Sel:dword, N:dword, rand:dword			; N передается по значению

local lrand:dword					; резервируем стек под локальные переменные
local LenMOne:byte
local numA:dword					
local numM:dword					
local divTheOne:dword
local divres:dword
local divider:dword
local divhelper:dword
local divsum:dword;
local rangesum:dword;
local submask:dword;

	pusha							; при вызове процедур рекомендуют сохранять все регистры 
	
									; инициализация переменных
	mov numA, 48271					; простое число для расчета по Лемеру
	mov numM, 2147483647	        ; максимальное положительное для расчета по Лемеру
	
	mov edx,dword ptr [rand]		; предыдущее ПСЧ берем из глобальной rand в локальную переменную lrand для инициализации ГПСЧ  
	mov edx,dword ptr [edx]			 
	mov lrand,edx					
	                                
	mov al,byte ptr [N]				; значние N из стека заносим в локальную переменную LenMOne
	mov LenMOne,al					
	
	
;РАСЧЕТ ВЕЛИЧИНЫ, ОБРАТНОЙ ОТКЛОНЕНИЮ ПОЛУЧЕННОГО РЕЗУЛЬТАТА 1/(D[i]-D)                         
	
	mov ebx,0						; цикл перебора по массиву результатов Res ( Di-D )
l4:                             	
	mov esi,dword ptr [Res]			; адрес первого элементат в массиве Res 
	mov esi,dword ptr [esi+ebx*4]	; выбор очередного элемента (вариант отклонения) из массива Res 
    mov divider,esi					; в переменную делитель (divider)
	                                
	mov divTheOne,1					; переменная с единицей для деления 
	mov divres,0					; переменная divres для хранения результата 
	
	mov ecx,0						; цикл 1..6 - деление единицы в столбик со сдвигом запятой в результате на 6 знаков вправо  

l3: 
	inc ecx						
	mov eax, divTheOne				
	cdq								; расширение знаоквого бита в edx
	idiv divider					; в eax целое от деления 1/Res[bl]
	mov divhelper,eax				
	test eax,eax					; содержится ли делитель в делимом хоть раз
	jz  l1							; 0 - нет: переход на l1, иначе ниже
	mov edx,divhelper				 
	mov eax,divider					
	imul eax,edx					; подготовка к вычитаемого для вычисления целого остатка от деления 
	sub divTheOne,eax				; в divTheOne остаток от деленя divTheOne на divider
	mov eax,divTheOne				; для следующего деления необходимо результат увеличить на 10
	imul eax,eax,0ah				; eax умножается на 10 (взято из собранного прототипа на Pascal-е)
	mov divTheOne,eax				; перезаписываем для следующей итерации
	jmp l2							; обход кода ниже

l1:
	mov eax,divTheOne				; нет целой части от деления 
	imul eax,eax,0ah				; умножаем еще на 10
	mov divTheOne,eax				

l2: 
	mov eax,divres					
	imul eax,eax,0ah				
	add eax,divhelper				; добавляем целый остаток для следующей итерации
	mov divres,eax					

	cmp cl,7
	jl l3							; конец тела цикла ( деление в столбик )
	
	mov edi,divres					; divres = результат деления 1/Res[i]*1000000
	mov esi,dword ptr [Res]			; замещаем обратным значением эелемент массива хранивший прямое значение разности D[i]-D,
	mov dword ptr [esi+ebx*4],edi	; так как для дальнешей селекции он нам уже не понадобится
	
	inc bl
	cmp bl,LenMOne
	jl l4							; конец тела цикла (перебор по массиву результатов Res ( D[i]-D ) )
	
	
	; для увеличения быстродействия алгоритма был применен метод отсечки описанный в учебном пособии,
	; для этого потребовалось выполнить сортировку по значениям обратных величин 1/(D[i]-D).
	; для сохранения соответствия массива Res и X, 
	; пятерки массива X перемещаются параллельно с перемещением элементов массива Res.
	
	mov al,byte ptr [N]				
	dec al							; для работы цикла по количеству особей завершаемого на 0 (0..N-1)
	mov LenMOne,al					; LenMOne=N-1
	
    mov esi,dword ptr [Res]    		; адреса на массивы из стека передаем в регистры 
	mov edi,dword ptr [X]   		
a2:    								; цикл сортировки по методу "пузырька"
	xor ecx,ecx
	mov cl,LenMOne   				; для вычисления адресов
    xor ebx,ebx        				; используется в качестве флага, если были перемещения элементов массива
a3: 
	mov eax,[esi+ecx*4-4]			; получаем значение очередного элемента    
    cmp [esi+ecx*4],eax    			; сравниваем со значением соседнего элемента
    jnb a4    						; если больше или равен - идем к следующему элементу
    setna bl    					; была перестановка - устанавливаем флаг
    xchg eax,[esi+ecx*4]			; меняем значение элементов местами
    mov [esi+ecx*4-4],eax			; меняем местами соответсвующие пятерки из X

	mov eax,5						; начинаем обмен пятерок из массива X через стек
	mul cl							; устанавливаем шаг 5 в eax
	push [edi+eax]  				; в стек 4 байта 
	push [edi+eax+4] 				; и еще 1 байт первого элемента обмена из X
	                                
	push [edi+eax-5] 				; в стек 4 байта  
	push [edi+eax-1] 				; и еще 1 байт второго элемента обмена из X
		                            
	pop edx	                        
	mov byte ptr [edi+eax+4],dl		; из стека 1 байт 
	pop [edi+eax] 					; и еще 4 байта в первый элемент обмена из X
	                                
	pop edx	                        
	mov byte ptr [edi+eax-1],dl		; из стека 1 байт 
	pop [edi+eax-5]					; и еще 4 байта во второй элемент обмена из X
	
a4: 
	loop a3    						; двигаемся до верхней границы массива
    add esi,4    					; сдвигаем границу массива Res
	add edi,5						; и позицию в массиве X
    dec ebx    						; проверяем были ли перестановки
    jnz finsort    					; если перестановок не было - то значит массив уже отсортирован - заканчиваем сортировку
	
    dec LenMOne        				; сдвигаем вниз границу, выше которой элементы уже отсортированы
    jnz a2							; если не ноль, то вероятно еще остались неотсортированные элементы 
			                        
finsort:							; конец сортировки


	; заполнение массива для селекции Sel 1..20 (10 мам + 10 пап), осуществляется 
	; индексами наиболее удачных особей из диапазона 0..K-1, то есть K особей.
	; наиболее удачные особи соответствуют наибольшим диапазонам/размерам обратных результатов 1/(D[i]-D) 
	; выбор производится на основе ГПСЧ ограниченного сверху суммой обратных результатов 1/(D[i]-D)
	; и сравнением с диапазонами/размерами обратных результатов 1/(D[i]-D) 
	
	mov divsum,0
	mov ecx,0
	mov esi,dword ptr [Res]
	
k1:	mov edi,dword ptr [esi+ecx*4]
	add divsum,edi
	inc cl
	cmp cl,byte ptr [N]
	jl k1
	
	mov ebx,divsum 					;заполнение старшим битом всех разрядов справа для маски случайного числа
	mov eax,ebx
	shr ebx,1
	or	ebx,eax
	mov eax,ebx
	shr ebx,2
	or	ebx,eax
	mov eax,ebx
	shr ebx,4
	or	ebx,eax
	mov eax,ebx
	shr ebx,8
	or	ebx,eax
	mov eax,ebx
	shr ebx,16
	or	ebx,eax
	mov submask,ebx					;маска в submask 
	

	mov esi,dword ptr [Sel] 		; адрес селекционного массива Sel 
	mov ecx, 0			    		; размер массива селекции 20 от 0..19
	mov edx,lrand 					; инициализация ГПСЧ
			                        
	next:			                
			                        
	mov eax,edx						; в eax предыдущее вычесленное псевдослучайное значение
	mul numA						; простое число для расчета по Лемеру
	div numM						; максимальное положительное для расчета по Лемеру
	                                
	mov lrand,edx								
									; должно остаться сл. значение меньше суммы divsum по маске из ebx
	mov ebx,edx	
	and ebx,submask
	mov edi,dword ptr [Res]			
	mov eax,0
	mov rangesum,0
k2:	
	push ebx						; здесь кончились свободные регистры пришлось использовать стек
	mov ebx,rangesum
	add ebx,dword ptr [edi+eax*4]	; команды сложения памяти с памятью не оказалось, поэтому используется ebx 
	mov rangesum,ebx
	pop ebx							; восстанавливаем ebx
	cmp ebx,rangesum
	jg k3 
	
	mov byte ptr[esi+ecx],al		
	jmp k4
k3:	
	inc al
	cmp al,byte ptr [N]
	jl k2
k4:
	inc cl
	cmp cl,20
	jl next
	
	mov edx,dword ptr[rand]
	mov eax,lrand					
	mov dword ptr[edx],eax			; возвращаем текущее значение ПСЧ из локальной переменной в глобальную rand
	
	popa							; восстанавливаем все регистры
	
  	ret 20							; восстанавливаем указатель стека
	
Selection endp





;МУТАЦИЯ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mutation proc	X:dword, rand:dword, N:dword	

	local Prob:byte
	local lrand:dword
	local numA:dword
	local numM:dword
	local localN:dword
	
	pusha

;реверс одного бита в зависимости от вероятности P
	mov Prob,al						;взять из параметра в AL вероятность мутации P
	
	mov edx,dword ptr [rand]
	mov edx,dword ptr [edx]
	mov lrand,edx
	
	mov eax,dword ptr [N]
	mov bl,5
	mul bl
	mov localN,eax
	
	mov numA, 48271	
	mov numM, 2147483647
	
	mov esi, dword ptr [X]
	mov ecx,0				
a1: 
	mov eax, lrand

	mul numA						;EAX=a * X(i-1) (умножаем eax на dword, указанный по адресу в numA=48271)
	div numM						;a * X(i-1) mod m (полученное произведение в eax делим на dword, указанного по адресу в numM=2147483647)
	                                
	mov lrand, edx	                
		                            
	mov al, byte ptr [Prob]			;в зависимости от вероятности выполнить мутацию
	cmp dl,al						;сравнить псевдослучайную величину с заданной вероятностью и принять решение о мутации
	jnb nextPair	                
									;сделать мутацию, если выше попало в процент вероятности
	and dl,7						;отбор значения для случайного номера бита в мутации
	push ecx						;сохраняем счетчик, так как использовать в сдвиге sh(l/r) можно только регистр ecx
    mov cl,dl	                    
	mov bl,1	                    
    shl bl,cl						;в bl маска для мутации
	pop ecx							;восстанавливаем счетчик 
	                                
rev:	                            
	xor byte ptr [esi+ecx],bl	    
	jz	rev							;вернуть обратно, если в результате мутации получился ноль

nextPair:							;предыдущий ген избежал мутации
	inc ecx	                        
	cmp ecx,localN	                
	jl a1	                        
		                            
	mov edx,dword ptr[rand]	        
	mov eax,lrand					;возвращаем текущее состояние случайного датчика
	mov dword ptr[edx],eax
	
	popa
	ret 12
Mutation endp





;СКРЕЩИВАНИЕ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
Skreshiv proc	Sel:dword, X:dword, rand:dword, XBuf:dword
	
;выбирается часть, которыми будут обмениваться
	local K:byte
	local addrXBuf:dword
	local lrand:dword
	local numA:dword
	local numM:dword
	local exchvar1:dword
	local exchvar2:dword
	local loop5:dword
	
	pusha
	
	mov esi,dword ptr [XBuf]
	mov addrXBuf, esi
	
	mov numA, 48271					;numA=48271
	mov numM, 2147483647			;numM=2147483647
		                            
	mov esi, dword ptr [X]			;esi=массив X
	mov edi, dword ptr [Sel]		;edi=массив Sel
		                            
	mov edx,dword ptr [rand]		;edx=rand
	mov edx,dword ptr [edx]	        
	mov lrand,edx					;lrand=edx=rand
		                            
	mov K,al						;K=al=значение N
		                            
	mov ecx,0						;ecx=0
a1:
	
	mov loop5,0

lp5:	
	xor ebx,ebx						;загрузка байтов для скрещивания в exchvar1 и exchvar2
	mov bl, byte ptr [edi+ecx*2]	;bl=sel[i+ecx*2]
	mov eax,5						;eax=5
	mul bl							;eax=sel[i+ecx*2]*5
	add eax,loop5
	mov bl, byte ptr [esi+eax]		;bl=массив X
	mov byte ptr [exchvar1], bl		;exchvar1=bl=массив X
	
	mov bl, byte ptr [edi+ecx*2+1]	;bl=sel
	mov eax,5						;eax=5
	mul bl							;al=bl(sel)*5
	add eax,loop5
	mov bl, byte ptr [esi+eax]		;bl=массив X
	mov byte ptr [exchvar2], bl		;exchvar2=bl=массив X

zeroTryAgain:
	mov bh,byte ptr [exchvar2]		;на случай повтора, если случится Xi в результате скрещивания будет равен 0
									;далее работаем только bh вместо exchvar2
	
	mov eax, lrand					;eax=lrand=edx=rand
									;два повтора для лучшего начального смешивания.							
	mul numA						;eax=a * X(i-1) (умножаем eax на dword, указанный по адресу в numA=48271)
	div numM						;a * X(i-1) mod m (полученное произведение в eax делим на dword, указанного по адресу в numM=2147483647)
	mov eax,edx						;eax=rand[i-1]
	mul numA						;eax=a * X(i-1) (умножаем eax на dword, указанный по адресу в numA=48271)
	div numM						;edx=
	
	mov lrand, edx					;lrand=edx=rand[i-1]
	
	and dl,15						;выбор 4 последних бит из dl=rand[i], выбор позиции рассечения хромосомы при скрещивании
	mov al,0ffh						;на случай, если сучайное число ровно восемь, заранее готовим маску перед прыжком (будет полное замещение хромосомы следующего родителя)
    cmp dl,8
	je nParent						;если 8, то это ситуация когда все биты берем от этого родителя
	
	and dl,7						;если выше не 8, то точно (число 0..7) тогда берем первые три бита
	cmp dl,0
	jz nParent						;без рассечения будут браться все биты из соотв. хромосомы след. родителя 
	mov al,0						;иначе выбираем только часть хромосом от обоих
	mov bl,0
rOne:
	shl al,1						;al=маска (1 заполнила все от точки рассечения до конца вправо на число бит из cl=три последние бита из dl=rand[i])
	add al,1
	
	inc bl
	cmp bl,dl
	jl rOne

nParent:		
	
    mov bl,al						;bl=копия маски из al
    and al,byte ptr [exchvar1]		;в al сохраняется результат and al и X[i] для отбора только тех бит, что 1 в al 
	not bl							;bl=инвертир маску для отбора недостающей части от хромосомы другого родителя
	and bh,bl						;наложили маску на X[i] другого родителя
	or  bh,al						;схлопнуни разрезанные чаcти в новую хромосому  Xi
			                        
	jz zeroTryAgain					;если хромосома оказалась равно нулю пробуем по другому еще раз через выбор другого места для разрезания
	                                
	mov eax,ecx	                    
	mov bl,5	                    
	mul bl	                        
	add eax,loop5	                
	add eax,addrXBuf	            
	mov byte ptr [eax],bh	        
		                            
	inc loop5	                    
	cmp loop5,5	                    
	jl lp5	                        
		                            
	inc cl	                        
	cmp cl,K	                    
	jl a1	                        
		                            
	mov edx,dword ptr[rand]	        
	mov eax,lrand					;возвращаем текущее состояние случайного датчика из локальной переменной 
	mov dword ptr[edx],eax
	
	popa
	ret 16
Skreshiv endp





;ВЫВОД РЕЗУЛЬТАТА~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OutResult proc X:dword		

	pusha
	mov edi,dword ptr [X]

	newline
	outstr "За "
	outword eax
	outstrln " итераций получено следующее решение:"
	outstr "X1="
	outword byte ptr [edi]
	outchar 9
	outstr "X2="
	outword byte ptr [edi+1]
	outchar 9
	outstr "X3="
	outword byte ptr [edi+2]
	outchar 9          
	outstr "X4="       
	outword byte ptr [edi+3]
	outchar 9          
	outstr "X5="       
	outword byte ptr [edi+4]
	outchar 9
	outstr "res-D 0"

	popa
	
	ret 4
OutResult endp

end
