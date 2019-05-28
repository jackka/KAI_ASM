;Comment
;A1*x1 + A2*x2 + A3*x3 + A4*x4 + A5*x5 = D,
;xi - неизвестные положительные целые, Ai, D, Р заданные положительные целые константы
;i=1,..,5
;размер начальной популяции N задают пользователь в диапазоне  4 <= N <= 10. 
;начальная популяция формируется случайным образом.
;критерии останова:
;1) превышение заданного пользователем количества итераций M;
;2) достижение нулевого значения целевой функции.
;вид селекции:	cлучайная схема
;вид скрещивания:	одноточечное
;мутация:	изменение случайно выбранного бита;
;количество скрещиваемых особей и вероятность мутации задаются пользователем.
;требования к программе
;программа должна работать в двух режимах:
;тестовый
;основной
;в тестовом режиме программа выводит на экран популяцию решений, получаемую на каждом шаге работы алгоритма. 
;в основном режиме выводится только решение, значение функции (невязка уравнения, которая в идеале должна обращаться в ноль) и количество сделанных итераций.
;все шаги алгоритма (генерация начальной популяции, селекция, скрещивание, мутация, вычисление целевой функции), должны быть реализованы в виде отдельных процедур.


include console.inc 

extern  PopulationGEN@8:near, OcenkaPopul@12:near, OutResult@4:near, Selection@20:near, Mutation@12:near, Skreshiv@12:near  ;внешние процедуры


.data
N    DB ?				;размер начальной популяции в диапазоне  4 <= N <= 10
X    DB 50 DUP (?)		;корни - генерируются алгоритмом

A    DB 5 DUP (?)		;вводит пользователь
D    DD ?				;вводит пользователь
M    DD ?				;количество итераций
K    DB ?				;количество скрещиваемых особей
P    DB ?				;вероятность мутации (1/p)

Mode DD ?			;режим работы

Res  DD 10 DUP (?)		;результаты вычисления уравнений
Sel  DB 20 DUP (?)		;результаты селекции

comCount DD	?			;номер итерации
rand DD ?				;переменная для генерации СЛЧ


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


	
	mov dword ptr [rand],01h	;инициализация rand=1
	
	mov ecx,0					
	mov esi, offset X 			;esi=адрес начала массива x
PopGen:
	
	push  offset rand			;в стек адрес rand
	push esi					;

	call PopulationGEN@8	


	add esi, 5					;перескакиваем через 5 байт, чтобы разместить новую пятерку
	inc cl						;
	cmp cl,byte ptr [N]			
	jne PopGen					;если не сгенерировано количество переменных, заданных пользователем, возврат на процедуру генерации
	
	mov comCount,1				;номер итерации=1
iteratioins:
	
	cmp byte ptr [Mode],0
	jnz ComMode0				;если выбран основной режим, переход
	newline
	outint comCount
	outchar 9					;табуляция
	outstrln "итереция.  X1..X5 перем.   расст. до решения"
	newline
ComMode0:						;основной режим
	
	mov ecx,0
	mov esi, offset X				;esi=адрес X
equation_calc:
		
	mov eax, dword ptr [D]			;eax=D
    push eax						;в стек D
	push esi						;в стек адрес на начала массива X
	push offset A					;в стек адрес на начала массива A
	
	call OcenkaPopul@12
	
	
	cmp eax,0			; решение найдено eax=SumOfMul
	je outresult		; идти на вывод и выход
	
	cmp byte ptr [Mode],0
	jnz ComMode			;если выбран основной режим, то на ComMode
	
	outstr " "					;вывод отладочных результатов
	outword byte ptr [esi]
	outchar 9
	outstr " "
	outword byte ptr [esi+1]
	outchar 9
	outstr " "
	outword byte ptr [esi+2]
	outchar 9
	outstr " "
	outword byte ptr [esi+3]
	outchar 9
	outstr " "
	outword byte ptr [esi+4]
	outchar 9
	outstr " res-D "
	outwordln eax


ComMode:										;если выбран основной режим

	mov dword ptr [ecx*4+Res], eax				;в массив Res=eax=res-D
	
	add esi, 5									;перепрыгнули в ESI на следующую пятерку
	inc cl
	cmp cl,byte ptr [N]
	jne equation_calc
	
	push offset rand							;заготовка для Selection в стек адрес rand
	xor eax,eax
	mov al, byte ptr [N]						;al=значение N
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
