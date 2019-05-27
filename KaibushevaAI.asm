Comment &
A1*x1 + A2*x2 + A3*x3 + A4*x4 + A5*x5 = D,
xi - ����������� ������������� �����, Ai � D � �������� ������������� ����� ���������
i=1,..,5
������ ��������� ��������� N ������ ������������ � ���������  4<= N<= 10. 
��������� ��������� ����������� ��������� �������.
�������� ��������:
1) ���������� ��������� ������������� ���������� �������� M;
2) ���������� �������� �������� ������� �������.
��� ��������  	:	c�������� ����� [4]
��� �����������	:	������������ [4]
�������			:	��������� �������� ���������� ����;
���������� ������������ ������ � ����������� ������� �������� �������������.
���������� � ���������
��������� ������ �������� � ���� �������:
��������
��������
� �������� ������ ��������� ������� �� ����� ��������� �������, ���������� �� ������ ���� ������ ���������. 
� �������� ������ ��������� ������ �������, �������� ������� (������� ���������, ������� � ������ ������ ���������� � ����) � ���������� ��������� ��������.
��� ���� ��������� (��������� ��������� ���������, ��������, �����������, �������, ���������� ������� �������), ������ ���� ����������� � ���� ��������� ��������.
&

include console.inc 

extern  PopulationGEN@8:near, OcenkaPopul@12:near, OutResult@4:near, Selection@20:near, Mutation@12:near, Skreshiv@12:near  ;������� ���������


.data
N    DB ?			;������ ��������� ��������� � ���������  4<= N<= 10
X    DB 50 DUP (?)	;����� - ������������ ����������
Xbuf DD 50 DUP (?)	;����� ��� ����������� 
A    DB 5 DUP (?)	;������ ������������
D    DD ?			;������ ������������
M    DD ?			;���������� ��������
K    DB ?			;���������� ������������ ������
P    DB ?			;����������� ������� (1/p)

Mode db ?			;����� ������

Res  DD 10 DUP (?)	;���������� ��������� ���������
Sel	 DB 20 DUP (?)	;���������� ��������

comCount dd	?		;�������� ����
rand DD ?


.code

start:

outstr "������� ����� ������ 1 - ��������, 0 - ��������: "
inintln  [Mode]

outstr "������� N � ��������� 4...10 : "
inintln  [N]					;������ ��������� ��������� � ���������  4<= N<= 10

outstr "A1="					;������ �� ���� A1
inintln [A]					
outstr "A2="					;������ �� ���� A2
inintln [A+1]				
outstr "A3="					;������ �� ���� A3
inintln [A+2]				
outstr "A4="					;������ �� ���� A4
inintln [A+3]				
outstr "A5="					;������ �� ���� A5
inintln [A+4]				
 
outstr "������� D : "			;��������� ���� ��������� 
inintln [D]				

outstr "������� M : "			;���������� ��������
inintln [M]         
                    
outstr "������� K : "			;���������� ������������ ������
inintln [K]         
                    
outstr "������� P : "			;����������� ������� (1/p)
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
	
	cmp byte ptr [Mode],0
	jnz ComMode0
	newline
	outint comCount
	outchar 9
	outstrln "��������.  X1..X5 �����.   �����. �� �������"
	newline
ComMode0:
	
	mov ecx,0
	mov esi, offset X
equation_calc:
		
	mov eax, dword ptr [D]
    push eax
	push esi			; ����� 5 �����
	push offset A		; ��� ������ �� ����� A. ��� ��� ����� ����� ������ OcenkaPopul@12
	
	call OcenkaPopul@12
	
	
	cmp eax,0			; ������� ������� 
	je outresult		; ���� �� ����� � �����
	
	cmp byte ptr [Mode],0
	jnz ComMode
	
	outstr " "
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
	mov al, byte ptr [N] 			;���������� �� ������
    push eax
	xor eax,eax
	mov al, byte ptr [P]			;���������� ���������������� ���������
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
	outstr "��������� ��������: "
	outword M
	outstr ". ������� �� �������."
	
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
