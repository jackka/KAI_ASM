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
								; ���� ������� ������� ����������, ���� ��������� �������� ������ 1-��� ����.							
	mul numA					; EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM					; a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)
	mov eax,edx					; ��������� � EAX ���������� ����������� ��������������� ��������
	mul numA					; EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM					; a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)
	
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


;����������
	
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
	mov al,byte ptr [esi+ecx]		; ������� ���������� � al
	mov bl,byte ptr [edi+ecx]		; ������� ��������� � bl
	
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










;��������

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
	
	l3: inc ecx						; ������� ��������� 1/res[i]
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
	
	mov esi,dword ptr [Res]			; ��������� ��������� ����� ������� ������� ��������� Di-D, ��� ��� ��� ��������� �������� �� ��� ��� �� �����
	mov dword ptr [esi+ebx*4],edi
	
	inc bl
	cmp bl,LenMOne
	jl l4


	mov al,byte ptr [N]
	dec al
	mov LenMOne,al
	
								;���������� �� Res ������� �������� ( � ������������ � ����������� ������������ ������� �� X )
								
    mov esi,dword ptr [Res]    	;��������������� �� ������
	mov edi,dword ptr [X]   	;��������������� �� ������
a2:    
	xor ecx,ecx
	mov cl,LenMOne    
    xor ebx,ebx        		;���� � ����/�� ���� ������������ � �������
a3: 
	mov eax,[esi+ecx*4-4]		;�������� �������� ���������� ��������    
    cmp [esi+ecx*4],eax    	;���������� �� ��������� ��������� ��������
    jnb a4    				;���� ������ ��� ����� - ���� � ���������� ��������
    setna bl    			;���� ������������ - ������� ����
    xchg eax,[esi+ecx*4]		;������ �������� ��������� �������
    mov [esi+ecx*4-4],eax
							;������ ������� �������������� ������� �� X

	mov eax,5
	mul cl
	push [edi+eax]  			;4 ����� 
	push [edi+eax+4] 			;1 ����

	push [edi+eax-5] 			;4 ����� 
	push [edi+eax-1] 			;1 ����
	
	pop edx
	mov byte ptr [edi+eax+4],dl	;1 ���� ����� �� ����� ����� ������ ���
	pop [edi+eax] 				;4 ����� 

	pop edx
	mov byte ptr [edi+eax-1],dl	;1 ���� ����� �� ����� ����� ������ ���
	pop [edi+eax-5]				;4 ����� 

	
a4: 
	loop a3    				;��������� ����� �� ������� �������
    add esi,4    			;�������� ������� ���������������� �������
	add edi,5				;� ������� � ������� �������
    dec ebx    				;��������� ���� �� ������������
    jnz finsort    				;���� ������������ �� ���� - ����������� ����������
    dec LenMOne        		;��������� ���������� ����������������� ���������
    jnz a2					;���� ���� ��� ����������������� �������� - �������� ����� ������
	
	
finsort:					; ����� ����������


							;�����, � ����������� �� ���� ������� ������ K ������ ������������� �� ����������� 
							;�������� �������� �������� ������� �� ����������� ����� 1 � ��������������� �� ����������� �������� Di-D.
							;
							;��������� ���������� ������� �� ��������� �� 1..� ������ �������� 1..20 (10 ��� + 10 ���), � ����� ����� N ��� � N ���


							; ��������� ����� ����������� ��������� ����� 1 (1/Di-D)
	mov divsum,0
	mov ecx,0
	mov esi,dword ptr [Res]
k1:	mov edi,dword ptr [esi+ecx*4]
	add divsum,edi
	inc cl
	cmp cl,byte ptr [N]
	jl k1
	
	mov ebx,divsum 				;���������� ������� ����� ���� �������� ������ ��� ����� ���������� �����
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
	mov submask,ebx							; ����� � submask 
	

	mov esi,dword ptr [Sel] 	; ��������������� �� ������
	mov ecx, 0			    	; ������ ������� �������� 20 �� 0..19
	mov edx,lrand 				; ������������� ����������
		
	next:		
		
	mov eax,edx					;��������� � EAX ���������� ����������� ��������������� ��������
	mul numA					;EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM					;a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)

	mov lrand,edx							
								;������ �������� ��. �������� ������ ����� divsum �� ����� �� ebx
	mov ebx,edx
	and ebx,submask
	mov edi,dword ptr [Res]			
	mov eax,0
	mov rangesum,0
k2:	
	push ebx						; ����� ��������� ��������� �������� �������� ������������ ����
	mov ebx,rangesum
	add ebx,dword ptr [edi+eax*4]	; �������� ������ � ������� ���, ������� ������������ ebx 
	mov rangesum,ebx
	pop ebx							; ��������������� eax
	cmp ebx,rangesum
	jg k3 
	mov byte ptr[ESI+ECX],al	; � ���� ��������� ������� � ������������ ������� � esi
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
	mov eax,lrand				;���������� ������� ��������� ���������� �������
	mov dword ptr[edx],eax
	
	popa
  	ret 20
Selection endp









;�������

Mutation proc	X:dword, rand:dword, N:dword
;������ ������ ���� � ����������� �� ����������� P

	local Prob:byte
	local lrand:dword
	local numA:DWORD
	local numM:DWORD
	local localN:dword
	
	pusha
	
	mov Prob,al			; ����� �� ��������� � AL ����������� ������� P
	
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

	mul numA					; EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM					; a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)

	mov lrand, edx
	
	mov al, byte ptr [Prob]		; � ����������� �� ����������� ��������� �������
	cmp dl,al					; �������� ��������������� �������� � �������� ������������ � ������� ������� � �������
	jnb nextPair
								; ������� �������, ���� ���� ������ � ������� �����������
	and dl,7					; ����� �������� ��� ���������� ������ ���� � �������
	push ecx					; ��������� �������, ��� ��� ������������ � ������ sh(l/r) ����� ������ ������� ecx
    mov cl,dl
	mov bl,1
    shl bl,cl					; � bl ����� ��� �������
	pop ecx						; ��������������� ������� 

rev:
	xor byte ptr [esi+ecx],bl
	jz	rev						; ������� ������� ���� ��������� ����
nextPair:						; ���������� ��� ������� �������
	
	inc ecx
	cmp ecx,localN
	jl a1
	
	
	mov edx,dword ptr[rand]
	mov eax,lrand				;���������� ������� ��������� ���������� �������
	mov dword ptr[edx],eax
	
	popa
	ret 12
Mutation endp












;�����������
	
Skreshiv proc	Sel:dword, X:dword, 
	
;���������� �����, �������� ����� ������������
; ???����������� �� ����� ����?
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
								; 2-� ������ ��� ������� ���������� ����������.							
	mul numA					; EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM					; a * X(i-1) mod m (���������� ������������ � EAX ����� �� dword, ���������� �� ������ � numM=2147483647)
	mov eax,edx					; ��������� � EAX ���������� ����������� ��������������� ��������
	mul numA					; EAX=a * X(i-1) (�������� EAX �� dword, ��������� �� ������ � numA=48271)
	div numM		
	
	mov dword ptr [prevRandom], edx
	
	and dl,7					; ����� �������� ��� ���������� ������ ���� � �����������
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

	
	push ecx					; ��������� ������� ���, ��� ��� ������������ � ������ sh(l/r) ����� ������ ������� ecx
    mov cl,dl
	mov al,1
    shl al,cl					; � al ����� ��� ������
	
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











;����� ����������

OutResult proc X:dword		

	pusha
	mov edi,dword ptr [X]

	newline
	outstr "�� "
	outword eax
	outstrln " �������� �������� ��������� �������:"
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
