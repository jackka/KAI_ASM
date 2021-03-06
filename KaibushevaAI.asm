Comment &
A1*x1 + A2*x2 + A3*x3 + A4*x4 + A5*x5 = D,
xi - ����������� ������������� �����, Ai, D, � �������� ������������� ����� ���������
i=1,..,5
������ ��������� ��������� N ������ ������������ � ���������  4 <= N <= 10. 
��������� ��������� ����������� ��������� �������.
�������� ��������:
1) ���������� ��������� ������������� ���������� �������� M;
2) ���������� �������� �������� ������� �������.
��� ��������:	c�������� �����
��� �����������:	������������
�������:	��������� �������� ���������� ����;
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

extern  PopulationGEN@8:near, OcenkaPopul@12:near, OutResult@4:near, Selection@20:near, Mutation@12:near, Skreshiv@16:near  ;������� ���������

.data
N    DB ?										; ������ ��������� ��������� � ���������  4 <= N <= 10
X    DB 50 DUP (?)								; ����� - ������������ ����������
XBuf DB 50 DUP (?)								; ����� - ���������� �� ����� �����������
A    DB 5 DUP (?)								; ���������� - ������ ������������
D    DD ?										; ��������� ���� ��������� - ������ ������������
M    DD ?										; ���������� �������� - ������ ������������
K    DB ?										; ���������� ��������
P    DB ?										; ����������� ������� (����� �� 0..255) ��� 255 ������������� 1
						                        
Mode DD ?										; ����� ������ (��������, ��������)
						                        
Res  DD 10 DUP (?)								; ������ ����������� ���������� ���������
Sel  DB 20 DUP (?)								; ������� ��� �������� ��������� � ���������� ��������
						                        
ComCount DD	?									; ������� ��������
rand DD ?										; ���������� ���������� ��� �������� ����������� ��������������� ��� 

.code
start:

;��???��? ���?��� �����?����~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
outstr "������� ����� ������ 1 - ��������, 0 - ��������: "
inintln  [Mode]

outstr "������� N � ��������� 4...10 : "
inintln  [N]									; ������ ��������� � ���������  4 <= N <= 10
				                                
outstr "A1="									; ������� �� ���� ����������� A
inintln [A]									    
outstr "A2="									
inintln [A+1]								    
outstr "A3="									
inintln [A+2]								    
outstr "A4="									
inintln [A+3]				
outstr "A5="									
inintln [A+4]								    
outstr "������� D : "							; ��������� ���� ��������� 
inintln [D]								        
				                                
outstr "������� M : "							; ���������� ��������
inintln [M]         				            
									            
outstr "������� K : "							; ���������� ��������
inintln [K]         				            
									            
outstr "������� P : "							; ����������� �������
inintln [P]				                        
				                                
;v?�?��?��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
	mov dword ptr [rand],01h					; ������������� rand=1
					                            
	mov ecx,0									
	mov esi, offset X 							; ����� ������� �������� ������� X
PopGen:				                            
	push offset rand							; ����� rand � ����
	push esi									; ���������� esi � ���� ( �������� �� ������� X )
				                                
	call PopulationGEN@8						; ��������� 5 ������������ �����
				                                
	add esi, 5									; �������� �� ������� X � ����� 5 
	
	inc cl										; ����� ���� ����� ��������� ������� �����
	cmp cl,byte ptr [N]							
	jne PopGen									
					                            
	mov ComCount,1								; ������ �������� ����� 

iteratioins:				
	cmp byte ptr [Mode],0
	jnz ComMode0								; �������� ����� ������������ � ����� ComMode0
	newline										; ����� ����� ������� � �������� ������
	outint ComCount								; �� ����� �������� ��������� ��������
	outchar 9									; ������ ��������� ��� ������������ �������� 
	outstrln "��������.  X1..X5 �����.      �����. �� �������"
	newline				                        

ComMode0:										; �������� �����
	
;������ ���������� �� D~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	mov esi, offset X							; ������ ������� X
	mov ecx,0									; ���� �� 0..N-1
equation_calc:

	mov eax, dword ptr [D]						
    push eax									; �������� ����� ���� �������� D
	push esi									; ����� ������� � ������� X �������� ����� ���� 
	push offset A								; ����� ������ ������� A �������� ����� ���� 
	call OcenkaPopul@12

	cmp eax,0									; � ������, ���� ������� ������� 
	je outresult								; ������� �� ����� ���������� � ����� 
	
	cmp byte ptr [Mode],0						; �������� �����?
	jnz ComMode									; ��� - ������� �������� �����
	
	outstr " "									; �������� �����
	outword byte ptr [esi]		                
	outchar 9					                ; ������������ �� ���������
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
	outstr "S(Di)-D = "
	outwordln eax

ComMode:										; �������� ����� ������
	mov dword ptr [Res+ecx*4], eax				; ���������� ������� Res ���������� Sum(D[i])-D
	
	add esi, 5									; � ����� 5 �������� �� ������� X ������� �����
	inc cl										; ����� ���� �����
	cmp cl,byte ptr [N]							
	jne equation_calc							

;��������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
												
	push offset rand							; �������� ���������� ���������� rand=��������� ��������������� ���
	xor eax,eax
	mov al, byte ptr [N]						
    push eax									; � ���� �������� N
	push offset Sel								; � ���� ����� Sel	
	push offset X								; � ���� ����� X
	push offset Res								; � ���� ����� Res
	call Selection@20

;�������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	xor eax,eax
	mov al, byte ptr [N] 						
    push eax			                        ; ���������� �������� N ����� ����
	xor eax,eax			                        
	mov al, byte ptr [P]						; ���������� �������� P ����� eax
	push offset rand			                ; �������� ���������� ���������� rand=��������� ��������������� ���
	push offset X			                    ; � ���� ����� X                                  
	call Mutation@12			                

;�����������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	push offset XBuf			                
	xor eax,eax			                        
	mov al,byte ptr [K] 			            
	push offset rand			                
	push offset X			                    
	push offset Sel			                    
	call Skreshiv@16			                
				                                
	xor ecx,ecx			                        
	mov al,K									; �������� ����� ������ ����� K ������ ����� ����������, ���������� � ���������� �����������
	mov bl,5			
	mul bl
	mov cl,al
	mov esi,offset XBuf
	mov edi,offset X
	rep movsb

	inc dword ptr [ComCount]
	mov eax,dword ptr [M]
	cmp dword ptr [ComCount],eax
	jna iteratioins						

;����� ����������~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	
	newline
	outstr "��������� ��������: "
	outword M									; ����� ���������� �������� M	
	outstr ". ������� �� �������."
	
	jmp lexit
	
outresult:
	mov eax,dword ptr [ComCount]
	push esi
	call OutResult@4

lexit:

newline
pause "������� ����� ������ ��� ������"
exit
end start
