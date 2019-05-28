include console.inc    

public PopulationGEN, OcenkaPopul, Selection, Skreshiv, Mutation 


.code

PopulationGEN proc X:dword, rand:dword

	local numA:DWORD
	local numM:DWORD
	
	pusha						;
	
	mov numA, 48271				
	mov numM, 2147483647
	
	mov edi, dword ptr [rand]	;edi=адрес rand
	mov esi, dword ptr [X]		;esi может поменяться при повторном заходе в процедуру esi=адрес в стеке, по кот лежит адрес X
	
	mov ecx,0
generate:
	
	mov eax, dword ptr [edi]	; eax=1
								; ниже генерит вдвойне интереснее, если выполнить алгоритм больше 1-ого раза.							
	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
;	mov eax,edx					; размещаем в EAX предыдущее вычесленное псевдослучайное значение
;	mul numA					; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
;	div numM					; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
	
	mov dword ptr [edi], edx	;по адресу rand размещаем X[i] для последующей генерации

	cmp dl,0					;если сгенеривался 0, то снова на генерацию
	jz generate
	
	mov byte ptr [esi+ecx],dl	;размещаем в массиве X сгенерированный байт
	
	
	
	inc ecx
	cmp ecx,5					
	jne generate				;как только сгенерировано 5 чисел, выходим из генерации
	
	
	popa
	ret 8						;X:dword, rand:dword
PopulationGEN endp


;ВЫЧИСЛЕНИЕ
	
OcenkaPopul proc A:dword, X:dword, D:DWORD
					
local SumOfMul:DWORD
;local xArray:dword
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

Selection proc Res: DWORD, X:dword, Sel:dword, N:dword, rand:dword			;N:dword через стек 4 байта

local lrand:dword
local LenMOne:byte
local numA:DWORD					;48271
local numM:DWORD					;2147483647
local divTheOne:DWORD
local divres:dword
local divider:dword
local divhelper:dword
;local divloop:byte;
local divsum:dword;
local rangesum:dword;
local submask:dword;


	mov numA, 48271	
	mov numM, 2147483647	

	pusha
	mov edx,dword ptr [rand]			;edx=ссылка на адрес rand в стеке
	mov edx,dword ptr [edx]				;edx=rand=ссылка на адрес rand в стеке
	mov lrand,edx						;lrand=rand
	
	mov al,byte ptr [N]					;al=N
	mov LenMOne,al						;LenMOne=al=N
	mov ebx,0							;ebx=0

    l4:
	mov esi,dword ptr [Res]				;esi=адрес Res[i]
	mov esi,dword ptr [esi+ebx*4]		;прыгаем на Res[i+1]
    mov divider,esi						;divider=esi=Res[i+1]
	
	mov divTheOne,1					
	mov divres,0
	mov ecx,0
	
	l3: inc ecx						;берем 7 цифр после запятой
	mov eax, divTheOne				;eax=1
	cdq								;для получения положительного результата от деления
	idiv divider					;divider=esi=Res[i+1]/eax
	mov divhelper,eax				;divhelper=целое от деления Res[i+1]/eax
	test eax,eax					;
	jz  l1							;если 0, переход на 11
	mov edx,divhelper				;edx=divhelper=целое от деления Res[i+1]/eax
	mov eax,divider					;eax=divider=esi=Res[i+1]/eax
	imul eax,edx					;					
	sub divTheOne,eax				;divTheOne=divTheOne-eax
	mov eax,divTheOne
	imul eax,eax,0ah				;eax=eax*10
	mov divTheOne,eax				;divTheOne=eax=eax*10
	jmp l2
	l1: mov eax,divTheOne
	imul eax,eax,0ah
	mov divTheOne,eax
	l2: mov eax,divres				;eax=0
	imul eax,eax,0ah				;eax=eax*10
	add eax,divhelper				;eax=eax+divhelper(целое от деления Res[i+1]/eax)
	mov divres,eax					;divres=eax=eax+divhelper(целое от деления Res[i+1]/eax)
	cmp cl,7
	jl l3

	
	mov edi,divres					;edi=divres=eax=eax+divhelper(целое от деления Res[i+1]/eax)
	
	mov esi,dword ptr [Res]			; сохраняем обращение через единицу затирая результат Di-D, так как для дальнешей селекции он нам уже не нужен
	mov dword ptr [esi+ebx*4],edi
	
	inc bl
	cmp bl,LenMOne
	jl l4

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
	mov submask,ebx					; маска в submask 
	

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
	
	
	mov byte ptr[ESI+ECX],al		; с нуля начинаюся индексы в селекционном массиве с esi
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
	jz	rev						; вернуть обратно, если в результате мутации получился ноль
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
	
Skreshiv proc	Sel:dword, X:dword, rand:dword
	
;выбирается часть, которыми будут обмениваться
	
	local K:byte
	local lrand:dword
	local numA:DWORD
	local numM:DWORD
	local exchvar1:dword
	local exchvar2:dword
	local loop5:dword
	
	pusha
	
	mov numA, 48271				;numA=48271
	mov numM, 2147483647		;numM=2147483647
	
	mov esi, dword ptr [X]		;esi=массив X
	mov edi, dword ptr [Sel]	;edi=массив Sel
	
	mov edx,dword ptr [rand]	;edx=rand
	mov edx,dword ptr [edx]
	mov lrand,edx				;lrand=edx=rand
	
	mov K,al					;K=al=значение N
	
	mov ecx,0					;ecx=0
a1:
	
	mov loop5,0
lp5:	
	mov eax, lrand					;eax=lrand=edx=rand
									; два повтора для лучшего начального смешивания.							
	mul numA						; EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM						; a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
	mov eax,edx						;EAX=rand[i-1]
	mul numA						;EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
	div numM						;edx=
	
	mov lrand, edx					;lrand=edx=rand[i-1]
	
	and dl,7						;выбор трех последних бит из dl=rand[i], отбор значения для случайного номера бита в скрещивании
	nop
	xor ebx,ebx
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

	
	push ecx					; сохраняем счетчик пар, так как использовать в сдвиге sh(l/r) можно только регистр ecx
	
    mov cl,dl					;cl=три последние бита из dl=rand[i]				
	mov al,1					; al=1
    shl al,cl					; al=маска (сдвинули 1 на число бит из cl=три последние бита из dl=rand[i])
	
    mov bl,al					;bl=маска
    mov cl,al					;cl=маска
    and al,byte ptr [exchvar1]	;наложили маску на X[i]
    mov dl,byte ptr [exchvar2]	;dl=байт из 
    not bl						;bl=инвертированная маска
    and byte ptr [exchvar2],bl  
    or  byte ptr [exchvar2],al
    and cl,dl
    and byte ptr [exchvar1],bl
    or  byte ptr [exchvar1],cl
    
	pop ecx
	
   	xor ebx,ebx
	mov bl, byte ptr [edi+ecx*2]
	mov eax,5
	mul bl
	mov bl, byte ptr [exchvar1]
	add eax,loop5
	mov byte ptr [esi+eax],bl

	
	mov bl, byte ptr [edi+ecx*2+1]
	mov eax,5
	mul bl
	mov bl,byte ptr [exchvar2]
	add eax,loop5
   	mov byte ptr [esi+eax],bl

	inc loop5
	cmp loop5,5
	jl lp5
	
	inc cl
	cmp cl,K
	jl a1
	
	
	mov edx,dword ptr[rand]
	mov eax,lrand				;возвращаем текущее состояние случайного датчика
	mov dword ptr[edx],eax
	
	
	popa
	ret 12
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
	outstr "res-D 0"


	
	popa
	
	ret 4
OutResult endp




end
