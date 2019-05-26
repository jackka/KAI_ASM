include console.inc    

public PopulationGEN, OcenkaPopul, Selection;, Skreshiv, Mutation, 


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
	cmp cl,5
	jl l3

	
	mov edi,divres
	
	mov esi,dword ptr [Res]
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
comment &								
	mov numA, 48271	
	mov numM, 2147483647	
	mov esi,dword ptr [Sel] 	; позиционируемся на массив
	mov ecx, 20			    	; размер массива селекции 20 от 0..19
	
	mov edx,lrand 				; инициализация генератора
		
	next:		
		
	mov eax,edx					;размещаем в EAX предыдущее вычесленное псевдослучайное значение
	mul numA					;EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					;a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
								; EDX =  (a * X(i-1) mod m)
								
								;должно остаться значение от 0 до 6, что будет селекцией из 7 оставшихся родителей 
	
	mov bl,dl
	and bl,00000111b
	dec bl
	cmp bl,6
	ja zerol
	jmp nzerol
zerol:
	mov byte ptr[ESI+ECX-1],00000110b	; заполение массива с конца
nzerol:	
	mov byte ptr[ESI+ECX-1],bl	; заполение массива с конца
	

	loop next					;на начало цикла
	
	
	return:
&

	mov edx,dword ptr[rand]
	mov eax,lrand				;возвращаем текущее состояние случайного датчика
	mov dword ptr[edx],eax
	
	popa
  	ret 20
Selection endp


;ВЫВОД РЕЗУЛЬТАТА

OutResult proc X:dword		

	pusha
	mov edi,dword ptr [X]

	
	newline
	outstrln "получено решение:"
	outstr "X1="
	outwordln byte ptr [edi]
	outstr "X2="
	outwordln byte ptr [edi+4]
	outstr "X3="
	outwordln byte ptr [edi+8]
	outstr "X4="
	outwordln byte ptr [edi+12]
	outstr "X5="
	outwordln byte ptr [edi+16]
	popa
	
	ret 4
OutResult endp




end
