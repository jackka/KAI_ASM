include console.inc    

public PopulationGEN, OcenkaPopul, Selection, Skreshiv, Mutation 

.code



;���������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PopulationGEN proc X:dword, rand:dword

	local numA:dword				; ����������� ���� ��� ��������� ����������
	local numM:dword
	
	pusha							; ��� ������ �������� ����������� ��������� ��� �������� 
									
	mov numA, 48271					; ������� ����� ��� ������� �� ������
	mov numM, 2147483647			; ������������ ������������� ��� ������� �� ������
	
	mov edi, dword ptr [rand]		; ����� rand �� ����� ����� ��������� ������
	mov esi, dword ptr [X]			; ����� X �� ����� ����� ��������� ������
		                            
	mov ecx,0	                    ; ���� (0..4) 5 �� ���������� X � ���������
	
generate:	                        	                            
	mov eax, dword ptr [edi]		; ������������� ���� �� ���������� ���������� rand
									; ������ ��� �� ������ �� ������������ 9.1
	mul numA						; eax=a * X(i-1) (�������� eax �� dword, ��������� �� ������ � numA=48271)
	div numM						; a * X(i-1) mod m (���������� ������������ � eax ����� �� dword, ���������� �� ������ � numM=2147483647)
		                            
	mov dword ptr [edi], edx		; ��������� ���������� ��� � ���������� ���������� rand ��� ����������� ������� ������� ���� � �������������� ���������� ���������
	                                
									
	cmp dl,0						; ���� � ��������� ����� ��� ������� 0, �� ��������� ������ (���� ���� ������ ������������)
	jz generate	                    
		                            
	mov byte ptr [esi+ecx],dl		; �����, ���������� �������� ��������� ��� ���� �� ����� � ��� ������ X (�������� �� ������� ����� ������� ����� ECX)
		                            
	inc ecx							
	cmp ecx,5						
	jne generate					; ����� ���� �����
		                            
	popa	                        ; ��������������� ��� ��������
	
	ret 8							; ��������������� ��������� �����
	
PopulationGEN endp




;������ ���������� �� D~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OcenkaPopul proc A:dword, X:dword, D:dword  ; ������ ���������� �� ��������� ��������� ����
			
local SumOfMul:dword				; ����������� ���� ��� ��������� ����������

	pusha							; ��� ������ �������� ����������� ��������� ��� �������� 
	
	mov ecx,0						; �������������� ���������� ( ������� ����� )
	mov SumOfMul,0					; ( ���������� ��� ����� )
	
	mov edi,dword ptr [X]			; ����� ���������� ����� ���� ������ �������� X � A 
	mov esi,dword ptr [A]			
	
SummMul:							; ���� �� 0 �� 5 �� ���������� X � ���������
	xor eax,eax						; ������������� eax ����� ��� ������������ ���������� ���������  
	mov al,byte ptr [esi+ecx]		; ������� ����������� A[i] � X[i]
	mov bl,byte ptr [edi+ecx]		
	mul bl							; ��������� A[i]*X[i]
	
	add SumOfMul,eax				; ��������� ���������� ���������
	
	inc ecx							 
	cmp ecx,5						
	jne SummMul						; ����� ���� �����

	mov edx,dword ptr [D]			; ���������� D ������������ � ��������� �� ��������, ������� ������ ����� �� �� �����
	sub SumOfMul,edx				; ��������� �������� ( ���������� �� ��������� �������� A1*X1+...+A5*X5-D ���� )
	
	popa							; ��������������� ��� ��������
	
	mov eax, SumOfMul				; ����� eax ���������� ���������, ��� ����� ��������������� ���������, ������� ����� ������ �� ��������� ��������� ������ eax
	
	ret 12							; ��������������� ��������� �����
	
OcenkaPopul endp




;��������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Selection proc Res: dword, X:dword, Sel:dword, N:dword, rand:dword			; N ���������� �� ��������

local lrand:dword					; ����������� ���� ��� ��������� ����������
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

	pusha							; ��� ������ �������� ����������� ��������� ��� �������� 
	
									; ������������� ����������
	mov numA, 48271					; ������� ����� ��� ������� �� ������
	mov numM, 2147483647	        ; ������������ ������������� ��� ������� �� ������
	
	mov edx,dword ptr [rand]		; ���������� ��� ����� �� ���������� rand � ��������� ���������� lrand ��� ������������� ����  
	mov edx,dword ptr [edx]			 
	mov lrand,edx					
	                                
	mov al,byte ptr [N]				; ������� N �� ����� ������� � ��������� ���������� LenMOne
	mov LenMOne,al					
	
	
;������ ��������, �������� ���������� ����������� ���������� 1/(D[i]-D)                         
	
	mov ebx,0						; ���� �������� �� ������� ����������� Res ( Di-D )
l4:                             	
	mov esi,dword ptr [Res]			; ����� ������� ��������� � ������� Res 
	mov esi,dword ptr [esi+ebx*4]	; ����� ���������� �������� (������� ����������) �� ������� Res 
    mov divider,esi					; � ���������� �������� (divider)
	                                
	mov divTheOne,1					; ���������� � �������� ��� ������� 
	mov divres,0					; ���������� divres ��� �������� ���������� 
	
	mov ecx,0						; ���� 1..6 - ������� ������� � ������� �� ������� ������� � ���������� �� 6 ������ ������  

l3: 
	inc ecx						
	mov eax, divTheOne				
	cdq								; ���������� ��������� ���� � edx
	idiv divider					; � eax ����� �� ������� 1/Res[bl]
	mov divhelper,eax				
	test eax,eax					; ���������� �� �������� � ������� ���� ���
	jz  l1							; 0 - ���: ������� �� l1, ����� ����
	mov edx,divhelper				 
	mov eax,divider					
	imul eax,edx					; ���������� � ����������� ��� ���������� ������ ������� �� ������� 
	sub divTheOne,eax				; � divTheOne ������� �� ������ divTheOne �� divider
	mov eax,divTheOne				; ��� ���������� ������� ���������� ��������� ��������� �� 10
	imul eax,eax,0ah				; eax ���������� �� 10 (����� �� ���������� ��������� �� Pascal-�)
	mov divTheOne,eax				; �������������� ��� ��������� ��������
	jmp l2							; ����� ���� ����

l1:
	mov eax,divTheOne				; ��� ����� ����� �� ������� 
	imul eax,eax,0ah				; �������� ��� �� 10
	mov divTheOne,eax				

l2: 
	mov eax,divres					
	imul eax,eax,0ah				
	add eax,divhelper				; ��������� ����� ������� ��� ��������� ��������
	mov divres,eax					

	cmp cl,7
	jl l3							; ����� ���� ����� ( ������� � ������� )
	
	mov edi,divres					; divres = ��������� ������� 1/Res[i]*1000000
	mov esi,dword ptr [Res]			; �������� �������� ��������� �������� ������� ��������� ������ �������� �������� D[i]-D,
	mov dword ptr [esi+ebx*4],edi	; ��� ��� ��� ��������� �������� �� ��� ��� �� �����������
	
	inc bl
	cmp bl,LenMOne
	jl l4							; ����� ���� ����� (������� �� ������� ����������� Res ( D[i]-D ) )
	
	
	; ��� ���������� �������������� ��������� ��� �������� ����� ������� ��������� � ������� �������,
	; ��� ����� ������������� ��������� ���������� �� ��������� �������� ������� 1/(D[i]-D).
	; ��� ���������� ������������ ������� Res � X, 
	; ������� ������� X ������������ ����������� � ������������ ��������� ������� Res.
	
	mov al,byte ptr [N]				
	dec al							; ��� ������ ����� �� ���������� ������ ������������ �� 0 (0..N-1)
	mov LenMOne,al					; LenMOne=N-1
	
    mov esi,dword ptr [Res]    		; ������ �� ������� �� ����� �������� � �������� 
	mov edi,dword ptr [X]   		
a2:    								; ���� ���������� �� ������ "��������"
	xor ecx,ecx
	mov cl,LenMOne   				; ��� ���������� �������
    xor ebx,ebx        				; ������������ � �������� �����, ���� ���� ����������� ��������� �������
a3: 
	mov eax,[esi+ecx*4-4]			; �������� �������� ���������� ��������    
    cmp [esi+ecx*4],eax    			; ���������� �� ��������� ��������� ��������
    jnb a4    						; ���� ������ ��� ����� - ���� � ���������� ��������
    setna bl    					; ���� ������������ - ������������� ����
    xchg eax,[esi+ecx*4]			; ������ �������� ��������� �������
    mov [esi+ecx*4-4],eax			; ������ ������� �������������� ������� �� X

	mov eax,5						; �������� ����� ������� �� ������� X ����� ����
	mul cl							; ������������� ��� 5 � eax
	push [edi+eax]  				; � ���� 4 ����� 
	push [edi+eax+4] 				; � ��� 1 ���� ������� �������� ������ �� X
	                                
	push [edi+eax-5] 				; � ���� 4 �����  
	push [edi+eax-1] 				; � ��� 1 ���� ������� �������� ������ �� X
		                            
	pop edx	                        
	mov byte ptr [edi+eax+4],dl		; �� ����� 1 ���� 
	pop [edi+eax] 					; � ��� 4 ����� � ������ ������� ������ �� X
	                                
	pop edx	                        
	mov byte ptr [edi+eax-1],dl		; �� ����� 1 ���� 
	pop [edi+eax-5]					; � ��� 4 ����� �� ������ ������� ������ �� X
	
a4: 
	loop a3    						; ��������� �� ������� ������� �������
    add esi,4    					; �������� ������� ������� Res
	add edi,5						; � ������� � ������� X
    dec ebx    						; ��������� ���� �� ������������
    jnz finsort    					; ���� ������������ �� ���� - �� ������ ������ ��� ������������ - ����������� ����������
	
    dec LenMOne        				; �������� ���� �������, ���� ������� �������� ��� �������������
    jnz a2							; ���� �� ����, �� �������� ��� �������� ����������������� �������� 
			                        
finsort:							; ����� ����������


	; ���������� ������� ��� �������� Sel 1..20 (10 ��� + 10 ���), �������������� 
	; ��������� �������� ������� ������ �� ��������� 0..K-1, �� ���� K ������.
	; �������� ������� ����� ������������� ���������� ����������/�������� �������� ����������� 1/(D[i]-D) 
	; ����� ������������ �� ������ ���� ������������� ������ ������ �������� ����������� 1/(D[i]-D)
	; � ���������� � �����������/��������� �������� ����������� 1/(D[i]-D) 
	
	mov divsum,0
	mov ecx,0
	mov esi,dword ptr [Res]
	
k1:	mov edi,dword ptr [esi+ecx*4]
	add divsum,edi
	inc cl
	cmp cl,byte ptr [N]
	jl k1
	
	mov ebx,divsum 					;���������� ������� ����� ���� �������� ������ ��� ����� ���������� �����
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
	mov submask,ebx					;����� � submask 
	

	mov esi,dword ptr [Sel] 		; ����� ������������� ������� Sel 
	mov ecx, 0			    		; ������ ������� �������� 20 �� 0..19
	mov edx,lrand 					; ������������� ����
			                        
	next:			                
			                        
	mov eax,edx						; � eax ���������� ����������� ��������������� ��������
	mul numA						; ������� ����� ��� ������� �� ������
	div numM						; ������������ ������������� ��� ������� �� ������
	                                
	mov lrand,edx								
									; ������ �������� ��. �������� ������ ����� divsum �� ����� �� ebx
	mov ebx,edx	
	and ebx,submask
	mov edi,dword ptr [Res]			
	mov eax,0
	mov rangesum,0
k2:	
	push ebx						; ����� ��������� ��������� �������� �������� ������������ ����
	mov ebx,rangesum
	add ebx,dword ptr [edi+eax*4]	; ������� �������� ������ � ������� �� ���������, ������� ������������ ebx 
	mov rangesum,ebx
	pop ebx							; ��������������� ebx
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
	mov dword ptr[edx],eax			; ���������� ������� �������� ��� �� ��������� ���������� � ���������� rand
	
	popa							; ��������������� ��� ��������
	
  	ret 20							; ��������������� ��������� �����
	
Selection endp





;�������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mutation proc	X:dword, rand:dword, N:dword	

	local Prob:byte
	local lrand:dword
	local numA:dword
	local numM:dword
	local localN:dword
	
	pusha

;������ ������ ���� � ����������� �� ����������� P
	mov Prob,al						;����� �� ��������� � AL ����������� ������� P
	
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

	mul numA						;EAX=a * X(i-1) (�������� eax �� dword, ��������� �� ������ � numA=48271)
	div numM						;a * X(i-1) mod m (���������� ������������ � eax ����� �� dword, ���������� �� ������ � numM=2147483647)
	                                
	mov lrand, edx	                
		                            
	mov al, byte ptr [Prob]			;� ����������� �� ����������� ��������� �������
	cmp dl,al						;�������� ��������������� �������� � �������� ������������ � ������� ������� � �������
	jnb nextPair	                
									;������� �������, ���� ���� ������ � ������� �����������
	and dl,7						;����� �������� ��� ���������� ������ ���� � �������
	push ecx						;��������� �������, ��� ��� ������������ � ������ sh(l/r) ����� ������ ������� ecx
    mov cl,dl	                    
	mov bl,1	                    
    shl bl,cl						;� bl ����� ��� �������
	pop ecx							;��������������� ������� 
	                                
rev:	                            
	xor byte ptr [esi+ecx],bl	    
	jz	rev							;������� �������, ���� � ���������� ������� ��������� ����

nextPair:							;���������� ��� ������� �������
	inc ecx	                        
	cmp ecx,localN	                
	jl a1	                        
		                            
	mov edx,dword ptr[rand]	        
	mov eax,lrand					;���������� ������� ��������� ���������� �������
	mov dword ptr[edx],eax
	
	popa
	ret 12
Mutation endp





;�����������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
Skreshiv proc	Sel:dword, X:dword, rand:dword, XBuf:dword
	
;���������� �����, �������� ����� ������������
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
		                            
	mov esi, dword ptr [X]			;esi=������ X
	mov edi, dword ptr [Sel]		;edi=������ Sel
		                            
	mov edx,dword ptr [rand]		;edx=rand
	mov edx,dword ptr [edx]	        
	mov lrand,edx					;lrand=edx=rand
		                            
	mov K,al						;K=al=�������� N
		                            
	mov ecx,0						;ecx=0
a1:
	
	mov loop5,0

lp5:	
	xor ebx,ebx						;�������� ������ ��� ����������� � exchvar1 � exchvar2
	mov bl, byte ptr [edi+ecx*2]	;bl=sel[i+ecx*2]
	mov eax,5						;eax=5
	mul bl							;eax=sel[i+ecx*2]*5
	add eax,loop5
	mov bl, byte ptr [esi+eax]		;bl=������ X
	mov byte ptr [exchvar1], bl		;exchvar1=bl=������ X
	
	mov bl, byte ptr [edi+ecx*2+1]	;bl=sel
	mov eax,5						;eax=5
	mul bl							;al=bl(sel)*5
	add eax,loop5
	mov bl, byte ptr [esi+eax]		;bl=������ X
	mov byte ptr [exchvar2], bl		;exchvar2=bl=������ X

zeroTryAgain:
	mov bh,byte ptr [exchvar2]		;�� ������ �������, ���� �������� Xi � ���������� ����������� ����� ����� 0
									;����� �������� ������ bh ������ exchvar2
	
	mov eax, lrand					;eax=lrand=edx=rand
									;��� ������� ��� ������� ���������� ����������.							
	mul numA						;eax=a * X(i-1) (�������� eax �� dword, ��������� �� ������ � numA=48271)
	div numM						;a * X(i-1) mod m (���������� ������������ � eax ����� �� dword, ���������� �� ������ � numM=2147483647)
	mov eax,edx						;eax=rand[i-1]
	mul numA						;eax=a * X(i-1) (�������� eax �� dword, ��������� �� ������ � numA=48271)
	div numM						;edx=
	
	mov lrand, edx					;lrand=edx=rand[i-1]
	
	and dl,15						;����� 4 ��������� ��� �� dl=rand[i], ����� ������� ���������� ��������� ��� �����������
	mov al,0ffh						;�� ������, ���� �������� ����� ����� ������, ������� ������� ����� ����� ������� (����� ������ ��������� ��������� ���������� ��������)
    cmp dl,8
	je nParent						;���� 8, �� ��� �������� ����� ��� ���� ����� �� ����� ��������
	
	and dl,7						;���� ���� �� 8, �� ����� (����� 0..7) ����� ����� ������ ��� ����
	cmp dl,0
	jz nParent						;��� ���������� ����� ������� ��� ���� �� �����. ��������� ����. �������� 
	mov al,0						;����� �������� ������ ����� �������� �� �����
	mov bl,0
rOne:
	shl al,1						;al=����� (1 ��������� ��� �� ����� ���������� �� ����� ������ �� ����� ��� �� cl=��� ��������� ���� �� dl=rand[i])
	add al,1
	
	inc bl
	cmp bl,dl
	jl rOne

nParent:		
	
    mov bl,al						;bl=����� ����� �� al
    and al,byte ptr [exchvar1]		;� al ����������� ��������� and al � X[i] ��� ������ ������ ��� ���, ��� 1 � al 
	not bl							;bl=�������� ����� ��� ������ ����������� ����� �� ��������� ������� ��������
	and bh,bl						;�������� ����� �� X[i] ������� ��������
	or  bh,al						;��������� ����������� ��c�� � ����� ���������  Xi
			                        
	jz zeroTryAgain					;���� ��������� ��������� ����� ���� ������� �� ������� ��� ��� ����� ����� ������� ����� ��� ����������
	                                
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
	mov eax,lrand					;���������� ������� ��������� ���������� ������� �� ��������� ���������� 
	mov dword ptr[edx],eax
	
	popa
	ret 16
Skreshiv endp





;����� ����������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
	outstr "res-D 0"

	popa
	
	ret 4
OutResult endp

end
