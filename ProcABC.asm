include console.inc    

public PopulationGEN, OcenkaPopul, Selection, Skreshiv, Mutation 


.code

PopulationGEN proc X:dword, rand:dword

	local numA:DWORD
	local numM:DWORD
	
	pusha
	
	mov numA, 48271
	mov numM, 2147483647
	
	mov edi, dword ptr [rand]
	mov esi, dword ptr [X]
	
	mov ecx,0
generate:
	
	mov eax, dword ptr [edi]
								; ниже генерит вдвойне интереснее, если выполнить алгоритм больше 1-ого раза.							
	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
	mov eax,edx					; размещаем в EAX предыдущее вычесленное псевдослучайное значение
	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
	
	mov dword ptr [edi], edx

	cmp dl,0
	jz generate
	
	mov byte ptr [esi+ecx],dl
	
	
	
	inc ecx
	cmp ecx,5
	jne generate
	
	
	popa
	ret 8
PopulationGEN endp


;ВЫЧИСЛЕНИЕ
	
OcenkaPopul proc A:dword, X:dword, D:DWORD
					
local SumOfMul:DWORD
local xArray:dword
	pusha
	
	mov ecx,0
	mov SumOfMul,0
	
	mov edi,dword ptr [X]
	mov esi,dword ptr [A]
	SummMul:
	
	
	xor eax,eax
	mov al,byte ptr [esi+ecx]		; готовим умножаемое в al
	mov bl,byte ptr [edi+ecx]		; готовим множитель в bl
	
	mul bl
	
	add SumOfMul,eax
	
	inc ecx
	cmp ecx,5
	jne SummMul

	mov edx,dword ptr [D]
	sub SumOfMul,edx
	
	popa
	mov eax, SumOfMul
	ret 12
OcenkaPopul endp










;СЕЛЕКЦИЯ

Selection proc Res: DWORD, X:dword, Sel:dword, N:dword, rand:dword

local lrand:dword
local LenMOne:byte
local numA:DWORD
local numM:DWORD
local divTheOne:DWORD
local divres:dword
local divider:dword
local divhelper:dword
local divloop:byte;
local divsum:dword;
local rangesum:dword;
local submask:dword;


	mov numA, 48271	
	mov numM, 2147483647	

	pusha
	mov edx,dword ptr [rand]
	mov edx,dword ptr [edx]
	mov lrand,edx
	
	mov al,byte ptr [N]
	mov LenMOne,al
	mov ebx,0

    l4:
	mov esi,dword ptr [Res]
	mov esi,dword ptr [esi+ebx*4]
    mov divider,esi
	
	mov divTheOne,1
	mov divres,0
	mov ecx,0
	
	l3: inc ecx						; деление столбиком 1/res[i]
	mov eax, divTheOne
	cdq
	idiv divider
	mov divhelper,eax
	test eax,eax
	jz  l1
	mov edx,divhelper
	mov eax,divider
	imul eax,edx
	sub divTheOne,eax
	mov eax,divTheOne
	imul eax,eax,0ah
	mov divTheOne,eax
	jmp l2
	l1: mov eax,divTheOne
	imul eax,eax,0ah
	mov divTheOne,eax
	l2: mov eax,divres
	imul eax,eax,0ah
	add eax,divhelper
	mov divres,eax
	cmp cl,7
	jl l3

	
	mov edi,divres
	
	mov esi,dword ptr [Res]			; сохраняем обращение через единицу затирая результат Di-D, так как для дальнешей селекции он нам уже не нужен
	mov dword ptr [esi+ebx*4],edi
	
	inc bl
	cmp bl,LenMOne
	jl l4


	mov al,byte ptr [N]
	dec al
	mov LenMOne,al
	
								;сортировка по Res методом пузырька ( в соответствии с сортировкой перемещаются пятерки из X )
								
    mov esi,dword ptr [Res]    	;позиционируемся на массив
	mov edi,dword ptr [X]   	;позиционируемся на массив
a2:    
	xor ecx,ecx
	mov cl,LenMOne    
    xor ebx,ebx        		;флаг – были/не были перестановки в проходе
a3: 
	mov eax,[esi+ecx*4-4]		;получаем значение очередного элемента    
    cmp [esi+ecx*4],eax    	;сравниваем со значением соседнего элемента
    jnb a4    				;если больше или равен - идем к следующему элементу
    setna bl    			;была перестановка - взводим флаг
    xchg eax,[esi+ecx*4]		;меняем значение элементов местами
    mov [esi+ecx*4-4],eax
							;меняем местами соответсвующие пятерки из X

	mov eax,5
	mul cl
	push [edi+eax]  			;4 байта 
	push [edi+eax+4] 			;1 байт

	push [edi+eax-5] 			;4 байта 
	push [edi+eax-1] 			;1 байт
	
	pop edx
	mov byte ptr [edi+eax+4],dl	;1 байт взять из стека можно только так
	pop [edi+eax] 				;4 байта 

	pop edx
	mov byte ptr [edi+eax-1],dl	;1 байт взять из стека можно только так
	pop [edi+eax-5]				;4 байта 

	
a4: 
	loop a3    				;двигаемся вверх до границы массива
    add esi,4    			;сдвигаем границу отсортированного массива
	add edi,5				;и позицию в большом массиве
    dec ebx    				;проверяем были ли перестановки
    jnz finsort    				;если перестановок не было - заканчиваем сортировку
    dec LenMOne        		;уменьшаем количество неотсортированных элементов
    jnz a2					;если есть еще неотсортированные элементы - начинаем новый проход
	
	
finsort:					; конец сортировки


							;далее, в зависимости от того сколько особей K заданы пользователем на скрещивание 
							;проводим селекцию случайно выбирая из развернутых через 1 и отсортированных по возрастанию разносей Di-D.
							;
							;заполняем случайными числами из диапазона от 1..К массив размером 1..20 (10 мам + 10 пап), а брать будем N пап и N мам


							; вычисляем сумму результатов обращения через 1 (1/Di-D)
	mov divsum,0
	mov ecx,0
	mov esi,dword ptr [Res]
k1:	mov edi,dword ptr [esi+ecx*4]
	add divsum,edi
	inc cl
	cmp cl,byte ptr [N]
	jl k1
	
	mov ebx,divsum 				;заполнение старшим битом всех разрядов справа для маски случайного числа
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
	mov submask,ebx							; маска в submask 
	

	mov esi,dword ptr [Sel] 	; позиционируемся на массив
	mov ecx, 0			    	; размер массива селекции 20 от 0..19
	mov edx,lrand 				; инициализация генератора
		
	next:		
		
	mov eax,edx					;размещаем в EAX предыдущее вычесленное псевдослучайное значение
	mul numA					;EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					;a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)

	mov lrand,edx							
								;должно остаться сл. значение меньше суммы divsum по маске из ebx
	mov ebx,edx
	and ebx,submask
	mov edi,dword ptr [Res]			
	mov eax,0
	mov rangesum,0
k2:	
	push ebx						; здесь кончились свободные регистры пришлось использовать стек
	mov ebx,rangesum
	add ebx,dword ptr [edi+eax*4]	; сложение памяти с памятью нет, поэтому потребовался ebx 
	mov rangesum,ebx
	pop ebx							; восстанавливаем eax
	cmp ebx,rangesum
	jg k3 
	mov byte ptr[ESI+ECX],al	; с нуля начинаюся индексы в селекционном массиве с esi
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
	mov eax,lrand				;возвращаем текущее состояние случайного датчика
	mov dword ptr[edx],eax
	
	popa
  	ret 20
Selection endp









;МУТАЦИЯ

Mutation proc	X:dword, rand:dword, N:dword
;реверс одного бита в зависимости от вероятности P

	local Prob:byte
	local lrand:dword
	local numA:DWORD
	local numM:DWORD
	local localN:dword
	
	pusha
	
	mov Prob,al			; взять из параметра в AL вероятность мутации P
	
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
	nop
	nop
	mov ecx,0				
a1: 
	mov eax, lrand

	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)

	mov lrand, edx
	
	mov al, byte ptr [Prob]		; в зависимости от вероятности выполнить мутацию
	cmp dl,al					; сравнить псевдослучайную величину с заданной вероятностью и принять решение о мутации
	jnb nextPair
								; сделать мутацию, если выше попало в процент вероятности
	and dl,7					; отбор значения для случайного номера бита в мутации
	push ecx					; сохраняем счетчик, так как использовать в сдвиге sh(l/r) можно только регистр ecx
    mov cl,dl
	mov bl,1
    shl bl,cl					; в bl маска для мутации
	pop ecx						; восстанавливаем счетчик 

rev:
	xor byte ptr [esi+ecx],bl
	jz	rev						; вернуть обратно если получился ноль
nextPair:						; предыдущий ген избежал мутации
	
	inc ecx
	cmp ecx,localN
	jl a1
	
	
	mov edx,dword ptr[rand]
	mov eax,lrand				;возвращаем текущее состояние случайного датчика
	mov dword ptr[edx],eax
	
	popa
	ret 12
Mutation endp












;СКРЕЩИВАНИЕ
	
Skreshiv proc	Sel:dword, X:dword, 
	
;выбирается часть, которыми будут обмениваться
; ???РАЗДЕЛИТЕЛЬ НА ЛЮБОМ БИТЕ?
	local prevRandom:dword
	local numA:DWORD
	local numM:DWORD
	local exchvar1:dword
	local exchvar2:dword
	
	pusha
	
	mov numA, 48271	
	mov numM, 2147483647
	
	mov esi, dword ptr [X]
	mov edi, dword ptr [Sel]
	
	mov ecx,0
a1:
	
	mov eax, dword ptr [prevRandom]
								; 2-а повтра для лучшего начального смешивания.							
	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
	mov eax,edx					; размещаем в EAX предыдущее вычесленное псевдослучайное значение
	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM		
	
	mov dword ptr [prevRandom], edx
	
	and dl,7					; отбор значения для случайного номера бита в скрещивании
;nop
	xor ebx,ebx
	mov bl, byte ptr [edi+ecx*2]
	mov eax,20
	mul bl
	mov bl, byte ptr [esi+eax]
	mov byte ptr [exchvar1], bl
	
	mov bl, byte ptr [edi+ecx*2+1]
	mov eax,20
	mul bl
	mov bl, byte ptr [esi+eax]
	mov byte ptr [exchvar2], bl

	
	push ecx					; сохраняем счетчик пар, так как использовать в сдвиге sh(l/r) можно только регистр ecx
    mov cl,dl
	mov al,1
    shl al,cl					; в al маска для обмена
	
    mov bl,al
    mov cl,al
    and al,byte ptr [exchvar1]	
    mov dl,byte ptr [exchvar2]
    not bl
    and byte ptr [exchvar2],bl  
    or  byte ptr [exchvar2],al
    and cl,dl
    and byte ptr [exchvar1],bl
    or  byte ptr [exchvar1],cl
   
   	xor ebx,ebx
	mov bl, byte ptr [edi+ecx*2]
	mov eax,20
	mul bl
	mov bl, byte ptr [exchvar1]
	mov byte ptr [esi+ebx],bl

	
	mov bl, byte ptr [edi+ecx*2+1]
	mov eax,20
	mul bl
	mov bl,byte ptr [exchvar2]
   	mov byte ptr [esi+ebx],bl
	
	
	pop ecx	
	
	cmp ecx,10
	jne a1
	
	popa
	ret 8
Skreshiv endp











;ВЫВОД РЕЗУЛЬТАТА

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
	outstr "Res-D="
	outwordln eax

	
	popa
	
	ret 4
OutResult endp




end
