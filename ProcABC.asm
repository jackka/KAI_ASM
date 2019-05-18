include console.inc    

public Random, Selection, Skreshiv, Mutation, Korni

.code

;RANDOM � ��������� 1...D
;�������� 10 ��������� ��������� ������� � ��������� 1...D
;	A11...A15
;	...
;	A51...A55

Random proc 


 M EQU 50
local X[M]:DWORD
local numA:DWORD
local numM:DWORD
local adrX:DWORD 
local intN:DWORD 

	mov numA, 48271
	mov numM, 2147483647
	
	xor EAX,EAX
	mov AL,M
	
;	inintln AL					;��������� AL ��������� �������� M<=10

;	mov byte ptr [M],AL			;�� ������ [M] ���������� �������� �������� ���� �� AL=M<=10

comment &
	outstr 'X['					; 
	outint byte ptr [X]			;�� ������ [X] �������� �� ��������� 0
	outstr ']='					;����� � ������� =
	inint AL					;AL = �������� X[0]
	&
	mov byte ptr [X],1			;�� ������ ������� �������� [X] ���������� ���� �� AL = �������� X[0]
	
    mov ECX,M					;�������������� ������� ECX=M
    lea ESI,X					;�������� ������ ������� �������� X � ESI
	
    jmp Random_Calc

 After_Random_Calc: 
    ;
    newline
    lea ESI,X					;�������� ������ �������� X � ESI 
    mov adrX,ESI				;adrX = ����� ������� �������� X
    mov EAX,M					;
    mov intN,EAX				;intN = M		
    nextX:						
    mov EAX,M					;
    sub EAX,intN				;EAX=M-intN
    outstr 'X['
	outint EAX
	outstr ']='					;X[i]=
    mov ESI,adrX				;��������� ESI �������� ������� �������� X
    mov EAX, dword ptr [ESI]	;��������� � EAX �������� �������� dword � ������, ���������� � ESI
    outwordln AL				;����� �������� X[i]
    add adrX,4					;������������ � adrX ����� 4 �����
    dec dword ptr [intN]
    jnz nextX
    ;
	jmp exit_proc
	
 Random_Calc:
	dec ECX					;ECX-1 (ECX=M=������ �������)
	jcxz return				;���� cx=0 (������� ��� �����), �� ��������� �������������
	next:					;���� cx �� ����� 0
	mov EAX,dword ptr[ESI]	;��������� � EAX ���������� �������� (�������� dword � ������, ���������� � ESI)
	mul dword ptr [numA]	;EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div dword ptr [numM]	;a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)
	
	;	cmp EBX,D
	;	ja next
	
	add ESI,4				;������������ � ESI ����� 4 �����
	mov dword ptr[ESI],EDX	;�������� �� ������ ESI �������� �� EDX (a * X(i-1) mod m) �������� dword
	loop next				;�� ������ �����
	return:
	jmp  After_Random_Calc

 exit_proc:

	ret
Random endp



;��������
;��������� �����
;��������� D1...D5
;���������� Di-D
;1/(Di-D)

;������������ ������������
;       1/(D1-D)                      1/(D5-D)
;  ______________________ ... ______________________
;  1/(D1-D)+...+1/(D5-D)       1/(D1-D)+...+1/(D5-D)

;����� ���� ��� ���������, � ������ ���� ���� �������, ����� 5 ����� �������
; 10 000 ��������� ��������� �����, ����������� ������� ��������=fitness. ��� ������� ����� ���� ���������?

Selection proc 
	

  	ret 
Selection endp




;�����������
	
Skreshiv proc			

;���������� �����, �������� ����� ������������
; ???����������� �� ����� ����?
	
	ret
Skreshiv endp


;�������

Mutation proc			

;������ ������ ����
	
	ret
Mutation endp


;����������
	
Korni proc			

	
	ret
Korni endp

end

