include console.inc    

public Random, Selection, Skreshiv, Mutation, Korni

.code

;RANDOM В ДИАПАЗОНЕ 1...D
;выбираем 10 вариантов случайных решений в диапазоне 1...D
;	A11...A15
;	...
;	A51...A55

Random proc 
    mov EBP,ESP
    mov ECX, dword ptr [EBP+4]
	
M EQU 50
X DD M DUP(0)

numA DD 48271
numM DD 2147483647
adrX DD ?
intN DD ?

	xor EAX,EAX
	mov AL,50
	
;	inintln AL					;присвоить AL введенное значение M<=10

;	mov byte ptr [M],AL			;по адресу [M] записываем значение размером байт из AL=M<=10
comment &
	outstr 'X['					; 
	outint byte ptr [X]			;по адресу [X] размещен по умолчанию 0
	outstr ']='					;вывод в консоль =
	inint AL					;AL = значение X[0]
	&
	mov byte ptr [X],1			;по адресу первого элемента [X] записываем байт из AL = значение X[0]
	
    mov ECX,M					;инициализируем счетчик ECX=M
    lea ESI,X					;загрузка адреса первого элемента X в ESI
	
    call Random_Calc			;вызов Random_Calc
    ;
    newline
    lea ESI,X					;загрузка адреса элемента X в ESI 
    mov adrX,ESI				;adrX = адрес первого элемента X
    mov EAX,M					;
    mov intN,EAX				;intN = M		
    nextX:						
    mov EAX,M					;
    sub EAX,intN				;EAX=M-intN
    outstr 'X['
	outint EAX
	outstr ']='					;X[i]=
    mov ESI,adrX				;присвоить ESI значение первого элемента X
    mov EAX, dword ptr [ESI]	;размещаем в EAX значение размером dword с адреса, указанного в ESI
    outwordln AL				;вывод значения X[i]
    add adrX,4					;перепрыгнули в adrX через 4 байта
    dec dword ptr [intN]
    jnz nextX
    ;
		Random_Calc proc
	
		dec ECX					;ECX-1 (ECX=M=размер массива)
		jcxz return				;если cx=0 (введены все числа), то процедура заканчивается
		next:					;если cx не равно 0
		mov EAX,dword ptr[ESI]	;размещаем в EAX предыдущее значение (размером dword с адреса, указанного в ESI)
		mul dword ptr [numA]	;EAX=a * X(i-1) (умножаем EAX на dword, указанный по адресу в numA=48271)
		div dword ptr [numM]	;a * X(i-1) mod m (полученное произведение в EAX делим на dword, указанного по адресу в numM=2147483647)
		
	;		cmp EBX,D
	;		ja next
	
		add ESI,4				;перепрыгнули в ESI через 4 байта
		mov dword ptr[ESI],EDX	;положили по адресу ESI значение из EDX (a * X(i-1) mod m) размером dword
		loop next				;на начало цикла
		return:
	
		ret 
		Random_Calc endp 


	ret
Random endp




;СЕЛЕКЦИЯ
;случайная схема
;вычисляем D1...D5
;расстояние Di-D
;1/(Di-D)

;коэффициенты выживаемости
;       1/(D1-D)                      1/(D5-D)
;  ______________________ ... ______________________
;  1/(D1-D)+...+1/(D5-D)       1/(D1-D)+...+1/(D5-D)

;выбор пяти пар родителей, у каждой пары один потомок, итого 5 новых решений
; 10 000 сторонняя игральная кость, вероятности каждого родителя=fitness. КАК ВЫБРАТЬ НОВУЮ ПАРУ РОДИТЕЛЕЙ?

Selection proc 
	

  	ret 
Selection endp




;СКРЕЩИВАНИЕ
	
Skreshiv proc			

;выбирается часть, которыми будут обмениваться
; ???РАЗДЕЛИТЕЛЬ НА ЛЮБОМ БИТЕ?
	
	ret
Skreshiv endp


;МУТАЦИЯ

Mutation proc			

;реверс одного бита
	
	ret
Mutation endp


;ВЫЧИСЛЕНИЕ
	
Korni proc			

	
	ret
Korni endp

end

