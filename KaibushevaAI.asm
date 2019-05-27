Comment &
A1*x1 + A2*x2 + A3*x3 + A4*x4 + A5*x5 = D,
xi - неизвестные положительные целые, Ai и D Р заданные положительные целые константы
i=1,..,5
размер начальной популяции N задают пользователь в диапазоне  4<= N<= 10. 
начальная популяция формируется случайным образом.
критерии останова:
1) превышение заданного пользователем количества итераций M;
2) достижение нулевого значениЯ целевой функции.
вид селекции  	:	cлучайная схема [4]
вид скрещиваниЯ	:	одноточечное [4]
мутация			:	изменение случайно выбранного бита;
количество скрещиваемых особей и вероятность мутации задаются пользователем.
требования к программе
программа должна работать в двух режимах:
тестовый
основной
в тестовом режиме программа выводит на экран популяцию решений, получаемую на каждом шаге работы алгоритма. 
в основном режиме выводится только решение, значение функции (невязка уравнения, которая в идеале должна обращаться в ноль) и количество сделанных итераций.
все шаги алгоритма (генерациЯ начальной популЯции, селекция, скрещивание, мутация, вычисление целевой функции), должны быть реализованы в виде отдельных процедур.
&

include console.inc 

extern  PopulationGEN@8:near, OcenkaPopul@12:near, OutResult@4:near, Selection@20:near, Mutation@12:near, Skreshiv@12:near  ;внешние процедуры


.data
N    DB ?			;размер начальной популяции в диапазоне  4<= N<= 10
X    DB 50 DUP (?)	;корни - генерируются алгоритмом
Xbuf DD 50 DUP (?)	;буфер для скрещивания 
A    DB 5 DUP (?)	;вводит пользователь
D    DD ?			;вводит пользователь
M    DD ?			;количество итераций
K    DB ?			;количество скрещиваемых особей
P    DB ?			;вероЯтность мутации (1/p)

Mode db ?			;режим работы

Res  DD 10 DUP (?)	;результаты вычиления уравнений
Sel	 DB 20 DUP (?)	;результаты селекции

comCount dd	?		;основной цикл
rand DD ?


.code

start:

outstr "введите режим работы 1 - основной, 0 - тестовый: "
inintln  [Mode]

outstr "введите N в диапазоне 4...10 : "
inintln  [N]					;размер начальной популяции в диапазоне  4<= N<= 10

outstr "A1="					;запрос на ввод A1
inintln [A]					
outstr "A2="					;запрос на ввод A2
inintln [A+1]				
outstr "A3="					;запрос на ввод A3
inintln [A+2]				
outstr "A4="					;запрос на ввод A4
inintln [A+3]				
outstr "A5="					;запрос на ввод A5
inintln [A+4]				
 
outstr "введите D : "			;свободный член уравнения 
inintln [D]				

outstr "введите M : "			;количество итераций
inintln [M]         
                    
outstr "введите K : "			;количество скрещиваемых особей
inintln [K]         
                    
outstr "введите P : "			;вероятность мутации (1/p)
inintln [P]


	
	mov dword ptr [rand],01h
	
	mov ecx,0
	mov esi, offset X 
PopGen:
	
	push  offset rand
	push esi

	call PopulationGEN@8	


	add esi, 5
	inc cl
	cmp cl,byte ptr [N]
	jne PopGen
	
	mov comCount,1
iteratioins:
	
	
	
	mov ecx,0
	mov esi, offset X
equation_calc:
		
	mov eax, dword ptr [D]
    push eax
	push esi			; пачка 5 иксов
	push offset A		; это ссылка на пачку A. что это пачка знает только OcenkaPopul@12
	
	call OcenkaPopul@12
	
	
	cmp eax,0			; решение найдено 
	je outresult		; идти на вывод и выход
	
	cmp byte ptr [Mode],0
	jnz ComMode
	
	newline
	outstr "отладка. итер.: "
	outint comCount
	outstr " "
	outchar 9
	outstr "X1="
	outword byte ptr [esi]
	outchar 9
	outstr "X2="
	outword byte ptr [esi+1]
	outchar 9
	outstr "X3="
	outword byte ptr [esi+2]
	outchar 9
	outstr "X4="
	outword byte ptr [esi+3]
	outchar 9
	outstr "X5="
	outword byte ptr [esi+4]
	outchar 9
	outstr "Res-D="
	outwordln eax


ComMode:

	mov dword ptr [ecx*4+Res], eax
	
	add esi, 5
	inc cl
	cmp cl,byte ptr [N]
	jne equation_calc
	
	push offset rand
	xor eax,eax
	mov al, byte ptr [N]
    push eax
	push offset Sel
	push offset X
	push offset Res
	
	call Selection@20


	xor eax,eax
	mov al, byte ptr [N] 			;передается по ссылке
    push eax
	xor eax,eax
	mov al, byte ptr [P]			;передается непосредственным значением
	push offset rand
	push offset X

	call Mutation@12

	xor eax,eax
	mov al,byte ptr [K] 
	push offset rand
	push offset X
	push offset Sel
	call Skreshiv@12

	
	inc dword ptr [comCount]
	mov eax,dword ptr [M]
	cmp dword ptr [comCount],eax
	jna iteratioins						
	

	newline
	outstr "выполнено итераций: "
	outword M
	outstr ". решение не найдено."
	
	jmp lexit
	
outresult:
	mov eax,dword ptr [comCount]
	push esi
	call OutResult@4

lexit:

newline
pause "press any key to exit"
exit
end start
