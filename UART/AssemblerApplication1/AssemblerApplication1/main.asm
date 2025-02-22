
		.DEF VALUE = R24
		.ORG 0
		RJMP MAIN
		.ORG 0X40
MAIN:
		LDI R16,HIGH(RAMEND)
		OUT SPH,R16
		LDI R16,LOW(RAMEND)
		OUT SPL,R16

		LDI R16,0XFF
		OUT DDRA,R16
		CBI PORTA,7		;KHONG CHO PHEP 573_COL
		CBI PORTA,6		;KHONG CHO PHEP 573_ROW
		
START:
		RCALL SETUP_MATRIX
	
		LDI	R16,(1<<RXEN0)
		STS UCSR0B,R16
		LDI R16,(1<<UCSZ01)|(1<<UCSZ00)
		STS UCSR0C,R16
		LDI R16,0
		STS UBRR0H,R16
		LDI R16,51
		STS UBRR0L,R16
WAIT:	LDS R17,UCSR0A
		SBRS R17,RXC0
		RJMP WAIT
		LDS VALUE,UDR0
		RCALL DELAY_500MS
		CPI VALUE,'Z'
		BREQ OPTION_KEY_Z
		CPI VALUE,'C'
		BREQ OPTION_KEY_C
		CPI VALUE,'A'
		BREQ OPTION_KEY_A
		CPI VALUE,'S'
		BREQ OPTION_KEY_S
		CPI VALUE,'D'
		BREQ OPTION_KEY_D
		CPI VALUE,'Q'
		BREQ OPTION_KEY_Q
		CPI VALUE,'W'
		BREQ OPTION_KEY_W
		CPI VALUE,'E'
		BREQ OPTION_KEY_E	
;--------------------------------
OPTION_KEY_Z:
		RCALL KEY_Z
		RJMP WAIT
;--------------------------------
OPTION_KEY_C:
		RCALL KEY_C
		RJMP WAIT
;--------------------------------
OPTION_KEY_A:
		RCALL KEY_A
		RJMP WAIT
;--------------------------------
OPTION_KEY_S:
		RCALL KEY_S
		RJMP WAIT
;--------------------------------
OPTION_KEY_D:
		INC R13
		RCALL KEY_D
		RJMP WAIT
;--------------------------------
OPTION_KEY_Q:
		RCALL KEY_Q
		RJMP WAIT
;--------------------------------
OPTION_KEY_W:
		INC R12
		RCALL KEY_W
		RJMP WAIT
;--------------------------------
OPTION_KEY_E:
		RCALL KEY_E
		RJMP WAIT
;=======================================================================================================
;CTC DIEU KIEN THUC HIEN PHIM W
;=======================================================================================================
;Moi lan nhan phim W, CTC co chuc nang tinh toan vi tri y de kiem tra vi tri diem sang co vuot qua matrix
;led moi theo chieu thang dung tu duoi len tren (A sang C hoac B sang D) hoac tran ra khoi Matrix led 16x16
;(vuot qua khoi Matrix C hay D) hay khong?
;Neu khong thi chi thuc hien CTC KEY_W_LESS_7 dich chuyen trong pham vi mot Matrix led.
;Neu co thi can phai thuc hien CTC KEY_W_MORE_7 de thuc hien nhay sang Matrix led moi sau do chuyen diem
;anh sang den Matrix led nay.
;=======================================================================================================
KEY_W:	
		PUSH R16				
		INC R10					;tang bien dem vi tri y
		MOV R16,R10					
		CPI R16,8				;kiem tra xem da vuot qua kich thuoc 1 Matrix led hay chua?
		BRCC OVER_KEY_W			;neu co thi nhay den nhan OVER_KEY_W
		RCALL KEY_W_LESS_7		;neu khong thi thuc hien CTC KEY_W_LESS_7
		RJMP EXIT_W			 
OVER_KEY_W:
		RCALL KEY_W_MORE_7		;thuc hien CTC KEY_W_MORE_7
		MOV R16,R0				;kiem tra xem diem sang co vuot ra ngoai Matrix led 16x16 hay khong?
		//MOV R2,R0
		CPI R16,2
		BRCC OVER_C_D_COL		;neu co thi nhay den nhan OVER_C_D_COL	
		RCALL KEY_W_LESS_7		;neu khong thi thuc hien CTC KEY_W_LESS_7 de hoan tat viec nhay sang Matrix led moi
		RJMP EXIT_W				
OVER_C_D_COL:					;thuc hien reset lai Matrix, sau do Set diem sang ngay tai vi tri x
		PUSH R13				;vi tri x la vi tri duoc xac dinh ngay truoc khi diem anh tran khoi Matrix 16x16	
		RCALL SETUP_MATRIX
		POP R16	
		CPI R16,0				;kiem tra xem x=0?
		BREQ EXIT_W				;neu x=0 thi bo qua SET_OVER_COL	
SET_OVER_COL:					;neu x>=1 thi thuc hien SET_OVER_COL	
		INC R13
		RCALL KEY_D
		DEC R16
		BRNE SET_OVER_COL
EXIT_W:							
		POP R16
		RET						;quay lai OPTION_KEY_W
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO CHIEU TU DUOI LEN TREN (Y) TRONG MOT MATRIX LED
;=======================================================================================================
;Truoc tien, kiem tra xem diem sang dang o matrix A,C (R1=0) hay B,D(R1=1) de dieu khien chinh xac phan cung
;cua thanh ghi dich
;=======================================================================================================
KEY_W_LESS_7:
		PUSH R16
		MOV R16,R1
		CPI R16,1				;kiem tra xem dang o Matrix led A,C hay B,D?
		BRCC MATRIX_B_D_Y		;o Matrix B hoac D
		SBI PORTA,7				;o Matrix A hoac C, su dung thanh ghi dich 595 dieu khien chan GND cua Matrix A,C
		SBI	PORTA,1				;tien hanh day tin hieu muc cao (=1) ra cac ngo song song
		CBI PORTA,0				;de dich chuyen diem len phia tren, moi lan nhan W diem
		SBI PORTA,0				;sang doi 1 don vi
		CBI PORTA,2		
		SBI PORTA,2
		CBI PORTA,0							
		CBI PORTA,7		
		RJMP EXIT_KEY_W_LESS_7
MATRIX_B_D_Y:					;o Matrix B hoac D
		SBI PORTA,7				;o Matrix B hoac D, su dung thanh ghi dich 595 dieu khien chan GND cua Matrix B,D
		SBI	PORTA,4				;tien hanh day tin hieu muc cao (=1) ra cac ngo song song
		CBI PORTA,3				;de dich chuyen diem len phia tren, moi lan nhan W diem
		SBI PORTA,3				;sang doi 1 don vi
		CBI PORTA,5		
		SBI PORTA,5
		CBI PORTA,3							
		CBI PORTA,7		
EXIT_KEY_W_LESS_7:				;thoat khoi CTC KEY_W_LESS_7
		POP R16
		RET
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO CHIEU TU DUOI LEN TREN (Y) KHI VUOT KHOI MATRIX LED
;=======================================================================================================
;Truoc tien, kiem tra xem diem sang dang o matrix A (R1=0) hay B (R1=1) de dieu khien chinh xac phan cung
;cua thanh ghi dich.
;Sau khi xac dinh duoc tien hanh chuyen diem sang ay len Matrix led tiep theo co toa do la Point(R13,8)
;R0=1
;=======================================================================================================
KEY_W_MORE_7:
		CLR R10					;xoa thanh ghi dem vi tri y trong 1 Matrix led 8x8
		MOV R16,R1
		CPI R16,1				;kiem tra xem dang o Matrix led A hay B?
		BRCC MATRIX_B_TO_D		;dang o matrix B

		//dang o Matrix A, khi vuot qua R10=7 thi nhay len Matrix C
		//toa do cua diem sang sau khi chuyen la Point(R13,8)
		SBI PORTA,6				;khoi tao muc tich cuc cao tai chan C_P0
		SBI PORTA,4				
		CBI PORTA,3		
		SBI PORTA,3		
		CBI PORTA,5		
		SBI PORTA,5
		MOV R6,R11				;xac dinh vi tri x truoc khi chuyen sang Matrix led C
		INC R6
		DEC R6					
		BREQ EXIT_KEY_W_MORE_7
		CBI PORTA,4				;sau do tien hanh doi muc tich cuc thap den vi tri x
SET_Y_W:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R6
		BRNE SET_Y_W	
		CBI PORTA,5		
		SBI PORTA,5
		RJMP EXIT_KEY_W_MORE_7
		
		//dang o Matrix B, khi vuot qua R10=7 thi nhay len Matrix D
		//toa do cua diem sang sau khi chuyen la Point(R13,8)
MATRIX_B_TO_D:
		SBI PORTA,6				;tao muc cao (=1) A_
		SBI PORTA,4		
		CBI PORTA,3				
		SBI PORTA,3	
		CBI PORTA,5		
		SBI PORTA,5	
		LDI R16,8				;truyen 8 lan muc thap (=0) truyen len ngo song song de D_P0=1
		CBI PORTA,4
SET_Y_8_W_MATRIX_D:
		CBI PORTA,3		
		SBI PORTA,3
		DEC R16
		BRNE SET_Y_8_W_MATRIX_D	
		CBI PORTA,5		
		SBI PORTA,5
		MOV R6,R11				;kiem tra toa do cua x trong Matrix led B
		INC R6
		DEC R6
		BREQ EXIT_KEY_W_MORE_7	;neu x=0 thi nhay den nhan ket thuc CTC
		CBI PORTA,4				;neu x>=1 tien hanh set x
SET_X_W_MATRIX_D:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R6
		BRNE SET_X_W_MATRIX_D	
		CBI PORTA,5		
		SBI PORTA,5	

EXIT_KEY_W_MORE_7:				;thoat khoi CTC
		CBI PORTA,3
		CBI PORTA,6			
		INC R0					;tang gia tri bien dem toa do Matrix led	
		RET
;=======================================================================================================
;CTC DIEU KIEN THUC HIEN PHIM D
;=======================================================================================================
;Moi lan nhan phim D, CTC co chuc nang tinh toan vi tri x de kiem tra vi tri diem sang co vuot qua matrix
;led moi theo chieu nam ngang tu trai sang phai (A sang B hoac C sang D) hoac tran ra khoi Matrix led 16x16 
;(vuot ra khoi Matrix B,D) hay khong?
;Neu khong thi chi thuc hien CTC KEY_D_LESS_7 dich chuyen trong pham vi mot Matrix led.
;Neu co thi can phai thuc hien CTC KEY_D_MORE_7 de thuc hien nhay sang Matrix led moi sau do chuyen diem
;anh sang den Matrix led nay.
;=======================================================================================================
KEY_D:	
		PUSH R16
		INC R11					;tang bien dem vi tri x
		MOV R16,R11				
		CPI R16,8				;kiem tra xem da vuot qua kich thuoc 1 Matrix led hay chua?
		BRCC OVER_KEY_D			;neu co thi nhay den nhan OVER_KEY_D
		RCALL KEY_D_LESS_7		;neu khong thi thuc hien CTC KEY_D_LESS_7
		RJMP EXIT_D					
OVER_KEY_D:
		RCALL KEY_D_MORE_7		;thuc hien CTC KEY_D_MORE_7
		MOV R16,R1				;kiem tra xem diem sang co vuot ra ngoai Matrix led 16x16 hay khong?
		CPI R16,2
		BRCC OVER_B_D_ROW		;neu co thi nhay den nhan OVER_B_D_ROW 
		RCALL KEY_D_LESS_7		;neu khong thi thuc hien CTC KEY_D_LESS_7 de hoan tat viec nhay sang Matrix led moi
		RJMP EXIT_D
OVER_B_D_ROW:					;thuc hien reset lai Matrix, sau do Set diem sang ngay tai vi tri y
		PUSH R12				;vi tri y la vi tri duoc xac dinh ngay truoc khi diem anh tran khoi Matrix 16x16
		RCALL SETUP_MATRIX
		POP R16
		CPI R16,0				;kiem tra xem y=0?
		BREQ EXIT_D				;neu y=0 thi bo qua SET_OVER_ROW
SET_OVER_ROW:					;neu y>=1 thi thuc hien SET_OVER_ROW
		INC R12
		RCALL KEY_W
		DEC R16
		BRNE SET_OVER_ROW
EXIT_D:
		POP R16
		RET						;quay lai OPTION_KEY_D
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO CHIEU TU TRAI SANG PHAI (X) TRONG MOT MATRIX LED
;=======================================================================================================
;Truoc tien, kiem tra xem diem sang dang o matrix A,B (R0=0) hay C,D(R0=1) de dieu khien chinh xac phan cung
;cua thanh ghi dich
;=======================================================================================================
KEY_D_LESS_7:
		PUSH R16		
		MOV R16,R0			
		CPI R16,1				;kiem tra xem dang o Matrix led A,B hay C,D?
		BRCC MATRIX_C_D_X		;o Matrix C hoac D
		SBI PORTA,6				;o Matrix A hoac B, su dung thanh ghi dich 595 dieu khien chan P cua Matrix A,B
		CBI	PORTA,1				;tien hanh day tin hieu muc thap (=0) ra cac ngo song song
		CBI PORTA,0				;de dich chuyen diem sang sang ben phai, moi lan nhan, diem
		SBI PORTA,0				;sang doi 1 don vi		
		CBI PORTA,2		
		SBI PORTA,2	
		CBI PORTA,0
		CBI PORTA,6			
		RJMP EXIT_KEY_D_LESS_7	;dich chuyen xong thi nhay den nhan EXIT_KEY_D_LESS_7
MATRIX_C_D_X:					;o Matrix C hoac D
		SBI PORTA,6				;o Matrix C hoac D, su dung thanh ghi dich 595 dieu khien chan P cua Matrix C,D
		CBI	PORTA,4				;tien hanh day tin hieu muc thap (=0) ra cac ngo song song
		CBI PORTA,3				;de dich chuyen diem sang sang ben phai, moi lan nhan D diem
		SBI PORTA,3				;sang doi 1 don vi	
		CBI PORTA,5		
		SBI PORTA,5
		CBI PORTA,3	
		CBI PORTA,6		
EXIT_KEY_D_LESS_7:				;thoat khoi CTC KEY_D_LESS_7
		POP R16
		RET
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO CHIEU TU TRAI SANG PHAI (X) KHI VUOT KHOI MATRIX LED
;=======================================================================================================
;Truoc tien, kiem tra xem diem sang dang o matrix A (R0=0) hay C(R0=1) de dieu khien chinh xac phan cung
;cua thanh ghi dich.
;Sau khi xac dinh duoc tien hanh chuyen diem sang ay len Matrix led tiep theo co toa do la Point(8,R12)
;R1=1
;=======================================================================================================
KEY_D_MORE_7:
		CLR R11					;xoa thanh ghi dem vi tri x trong 1 Matrix led 8x8
		MOV R16,R0				
		CPI R16,1				;kiem tra xem dang o Matrix led A hay C?
		BRCC MATRIX_C_TO_D		;dang o matrix C

		//dang o Matrix A, khi vuot qua R11=7 thi nhay sang Matrix B 
		//toa do cua diem sang sau khi chuyen la Point(8,R12)
		SBI PORTA,7				
		CBI PORTA,4				;khoi tao muc tich cuc thap tai chan B_GND0 cua matrix B
		CBI PORTA,3		
		SBI PORTA,3		
		CBI PORTA,5		
		SBI PORTA,5
		MOV R5,R10				;xac dinh vi tri y truoc khi chuyen sang Matrix led B
		INC R5	
		DEC R5
		BREQ EXIT_KEY_D_MORE_7	;neu y=0 thi bo qua, nhay den nhan thoat
		SBI PORTA,4				;sau do tien hanh doi muc tich cuc thap o B_GND0 den vi tri B_GNDy	
UP_1:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R5
		BRNE UP_1	
		CBI PORTA,5		
		SBI PORTA,5	
		RJMP EXIT_KEY_D_MORE_7	;nhay den nhan thoat

		//dang o Matrix C, khi vuot qua R11=7 thi nhay sang Matrix D
		//toa do cua diem sang sau khi chuyen la Point(8,R12)
MATRIX_C_TO_D:
		SBI PORTA,7				
		CBI PORTA,4				;tao muc tich cuc thap o B_GND0
		CBI PORTA,3	
		SBI PORTA,3
		CBI PORTA,5		
		SBI PORTA,5	
		LDI R16,8				;day muc tich cuc thap o B_GND0 len D_GND0
		SBI PORTA,4
LOOP_595_COL_2:
		CBI PORTA,3		
		SBI PORTA,3
		DEC R16
		BRNE LOOP_595_COL_2		
		CBI PORTA,5		
		SBI PORTA,5
		MOV R5,R10				;xac dinh vi tri y truoc khi chuyen sang Matrix led D
		INC R5
		DEC R5
		BREQ EXIT_KEY_D_MORE_7	;neu y=0 thi bo qua, nhay den nhan thoat
		SBI PORTA,4				;sau do tien hanh doi muc tich cuc thap o D_GND0 den vi tri D_GNDy
UP_2:
		CBI PORTA,3		
		SBI PORTA,3	
		DEC R5
		BRNE UP_2	
		CBI PORTA,5		
		SBI PORTA,5

EXIT_KEY_D_MORE_7:				;thoat khoi CTC
		CBI PORTA,3	
		CBI PORTA,7			
		INC R1
		RET
;=======================================================================================================
;CTC DIEU KIEN THUC HIEN PHIM A
;=======================================================================================================
;Moi lan nhan phim A, CTC co chuc nang tinh toan vi tri x de kiem tra vi tri diem sang co vuot qua matrix
;led moi theo chieu nam ngang tu phai sang trai (B sang A hoac D sang C) hoac tran ra khoi Matrix led 16x16
;(vuot ra khoi Matrix A,C) hay khong?
;Neu khong thi chi thuc hien reset Matrix led, sau do set Point(R13-1,R12)
;Neu co thi can phai nhay sang Matrix led moi sau do chuyen diem anh sang len Matrix led nay, diem sang 
;se co toa do la Point(15,R12)
;=======================================================================================================
KEY_A:
		PUSH R12				;cat gia tri toa do y vao stack
		PUSH R13				;cat gia tri toa do x vao stack
		RCALL SETUP_MATRIX		;reset lai Matrix led	
		POP R13					;lay gia tri toa do x xuong de xu ly
		DEC R13					;giam x di 1 don vi (vi nhan A sang trai)
		MOV R17,R13
		CPI R17,0				;kiem tra xem sau khi giam x thi co bi vuot ra khoi Matrix led theo huong tu phai sang trai hay khong?
		BRLT OVER_A_C_ROW		;neu co thi nhay den nhan OVER_A_C_ROW de xu ly 	
		CPI R17,1				;neu khong thi kiem tra xem sau khi giam x thi x=0?	
		BRCS MOVE_ROW_S			;neu co thi nhay den nhan MOVE_ROW_S de xu ly
SET_X_A:						;thuc hien set toa do x sau khi nhan A
		RCALL KEY_D
		DEC R17
		BRNE SET_X_A
MOVE_ROW_S:						
		POP R12					;lay gia tri toa do y xuong de xu ly
		MOV R17,R12
		CPI R17,1				;kiem tra xem toa do y co y=0?
		BRCS EXIT_A				;neu co thi nhay den nhan EXIT_A de thoat
SET_Y_A:						;neu khong thi thuc hien set toa do y sau khi nhan A
		RCALL KEY_W
		DEC R17					;luu y toa do y sau khi nhan A la khong thay doi so voi truoc khi nhan A
		BRNE SET_Y_A
		RJMP EXIT_A

		// khi giam x thi phat hien tran ra khoi Matrix led theo huong tu phai sang trai
		//can phai set Point(15,y)						
OVER_A_C_ROW:					
		RCALL SETUP_MATRIX			;reset lai Matrix led
		LDI R16,15					;set x=15
SET_X_AFTER_OVER_A_C_ROW:
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_AFTER_OVER_A_C_ROW
		POP R16						;lay gia tri y xuong de xu ly		
SET_Y_AFTER_OVER_A_C_ROW:			;set y
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_AFTER_OVER_A_C_ROW
EXIT_A:	RET							;thoat khoi nut A
;=======================================================================================================
;CTC DIEU KIEN THUC HIEN PHIM S
;=======================================================================================================
;Moi lan nhan phim S, CTC co chuc nang tinh toan vi tri y de kiem tra vi tri diem sang co vuot qua matrix
;led moi theo chieu thang dung tu tren xuong duoi (C sang A hoac D sang B) hoac tran ra khoi Matrix led 16x16
;(vuot ra khoi Matrix A,B) hay khong?
;Neu khong thi chi thuc hien reset Matrix led, sau do set Point(R13,R12-1)
;Neu co thi can phai nhay sang Matrix led moi sau do chuyen diem anh sang len Matrix led nay, diem sang 
;se co toa do la Point(R13,15)
;=======================================================================================================
KEY_S:	
		PUSH R13				;cat gia tri x vao stack
		PUSH R12				;cat gia tri y vao stack
		RCALL SETUP_MATRIX		;reset lai Matrix led 16x16
		POP R12					;lay gia tri y tu stack xuong
		DEC R12					;giam 1 don vi do nhan nut S
		MOV R17,R12				
		CPI R17,0				;so sanh xem y co be hon 0 hay khong?
		BRLT OVER_A_B_COL		;neu co thi nhay den nhan OVER_A_B_COL xu ly tran cot
		CPI R17,1				;neu khong thi kiem tra xem y co be hon 1 hay khong?
		BRCS MOVE_ROW			;neu co (y=0) thi nhay den nhan MOVE_ROW bo qua buoc set y
LP_KEY_S_COL:					;neu khong (y>=1) thi thuc hien set y
		RCALL KEY_W					
		DEC R17					;doi hang (R12-1) lan
		BRNE LP_KEY_S_COL			
MOVE_ROW:						;set x
		POP R13					;lay gia tri x xuong
		MOV R17,R13					
		CPI R17,1				;so sanh xem x=1?
		BRCS EXIT_S				;neu x=0 thi thoat CTC KEY_S
MOVE_COL:						;x>=1 thi tien hanh set x
		RCALL KEY_D					
		DEC R17					
		BRNE MOVE_COL			
		RJMP EXIT_S		
		//xu ly khi nhan S bi tran cot, dat Point(R13,15)			
OVER_A_B_COL:						
		RCALL SETUP_MATRIX		;reset lai Matrix led 16x16	
		LDI R16,15				;thuc hien viec set y=15
SET_Y_AFTER_OVER_A_B_COL:
		RCALL KEY_W
		INC R12					
		DEC R16
		BRNE SET_Y_AFTER_OVER_A_B_COL
		POP R16					;lay gia tri x xuong
		CPI R16,0
		BREQ EXIT_S
SET_X_AFTER_OVER_A_B_COL:		;thuc hien set x=R13 (khong thay doi gia tri x)
		RCALL KEY_D				
		INC R13
		DEC R16
		BRNE SET_X_AFTER_OVER_A_B_COL 
EXIT_S:	
		OUT PORTC,R13
		RET						;thoat nut nhan S
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO DUONG CHEO KHI NHAN PHIM (Z)
;=======================================================================================================
;**Mot so khai niem duoc su dung trong CTC:
;-  Duong cheo chinh nguoc: la duong cheo xuat phat tu (15,15) --> (0,0)
;-  Nguoc_Tren_Chinh: la duong cheo cung huong, nam phia tren Duong cheo chinh nguoc
;-  Nguoc_Duoi_Chinh: la duong cheo cung huong, nam phia duoi Duong cheo chinh nguoc
;**Truoc tien, kiem tra xem diem sang sau khi nhan E co vuot ra khoi (0,0) hay khong. Neu co thi roi vao 
;truong hop "vuot Duong cheo chinh nguoc". Khi do nhay den nhan xu ly truong hop nay.
;**Neu khong xay ra "vuot Duong cheo chinh nguoc" thi can kiem tra xem diem sang sau khi nhan E co vuot duong
;cheo tren "Nguoc_Tren_Chinh" hay vuot duong cheo duoi "Nguoc_Duoi_Chinh" hay khong? Neu co thi nhay den nhan 
;xu ly cac truong hop nay.
;**Neu khong xay ra cac truong tren thi sau khi nhan Z thi giong nhu sau khi Reset Matrix led thi lan luot
;nhan to hop hai phim W va D voi so luong thich hop.
;=======================================================================================================
KEY_Z:		
		MOV R16,R12										
		CPI R16,0						;kiem tra toa do y=0? (sau khi nhan se y- vuot ra khoi (0,0))
		BREQ OVER_0_S_Z					;neu y=0 thi nhay den nhan	OVER_0_S_Z de kiem tra x
		RCALL KEY_S						;neu y>=1 thi thuc hien nhan Z nhu binh thuong
		RCALL KEY_A
		RJMP NEVER_OVER_0_0_Z			

OVER_0_S_Z:								;kiem tra toa do x=0? (sau khi nhan se x- vuot ra khoi (0,0))
		PUSH R13
		RCALL KEY_S
		POP R13
		MOV R16,R13
		CPI R16,0
		BREQ OVER_0_0_Z					;neu x=0 thi du dieu kien vuot duong cheo chinh nguoc, nhay den nhan OVER_0_0_Z de xu ly
		RCALL KEY_A						;neu x>=1 thi thuc hien nhan Z nhu binh thuong

		//thuc hien thao tac nhan Z khi chua vuot vuot Duong cheo chinh nguoc 
NEVER_OVER_0_0_Z:
		MOV R16,R12						
		CPI R16,15						;kiem tra xem co vuot duong cheo Nguoc_Duoi_Chinh hay khong?
		BRNE CHECK_Z_OVER_ROW			;neu khong thi kiem tra xem co vuot duong cheo Nguoc_Tren_Chinh hay khong?
		
		//truong hop vuot duong cheo Nguoc_Duoi_Chinh
		//sau khi vuot thi toa do cua diem anh sang la Point(15,y)
		PUSH R13						;cat gia tri x len stack (*luu y: x luc nay da -1 so voi vi tri vuot)
		RCALL SETUP_MATRIX				;reset lai Matrix led
		LDI R16,14
		POP R13
		SUB R16,R13						;lay vi tri y=15-(x-(-1))
SET_Y_Z:								;tien hanh set y
		RCALL KEY_W							
		INC R12
		DEC R16
		BRNE SET_Y_Z
		LDI R16,15
		CLR R13							;lam sach x truoc khi tien hanh set x
SET_X_15_Z:								;tien hanh set x=15
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_15_Z
		RJMP EXIT_OPTION_KEY_Z			;thoat khoi phim nhan Z
		
		
CHECK_Z_OVER_ROW:
		MOV R16,R13
		CPI R16,15						;kiem tra xem co vuot duong cheo Nguoc_Tren_Chinh hay khong?
		BRNE EXIT_OPTION_KEY_Z			;neu khong thi nhay den nhan thoat
		
		//truong hop vuot duong cheo Nguoc_Tren_Chinh
		//sau khi vuot thi toa do cua diem anh sang la Point(x,15)
		PUSH R12						;cat gia tri y len stack (*luu y: y luc nay da -1 so voi vi tri vuot)
		RCALL SETUP_MATRIX				;reset lai Matrix led
		LDI R16,14						
		POP R12							
		SUB R16,R12						;lay vi tri x=15-(y-(-1))
SET_X_Z:								;tien hanh set x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Z
		LDI R16,15
		CLR R12							;lam sach y truoc khi set y
SET_Y_15_Z:								;set y=15
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_15_Z
		RJMP EXIT_OPTION_KEY_Z			;thoat khoi phim nhan Z

		//truong hop E vuot Duong cheo chinh nguoc
		//can set Point(15,15) nen chi can reset lai va thuc hien hai thao tac KEY_W va KEY_D 15 lan
OVER_0_0_Z:
		CLR R12
		CLR R13
		RCALL SETUP_MATRIX				;reset lai Matrix led
		LDI R16,15
SET_POINT_15_15:						;tien hanh set Point(15,15)
		RCALL KEY_D
		INC R13
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_POINT_15_15
EXIT_OPTION_KEY_Z:						;thoat khoi phim nhan
		RET
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO DUONG CHEO KHI NHAN PHIM (E)
;=======================================================================================================
;**Mot so khai niem duoc su dung trong CTC:
;-  Duong cheo Chinh: la duong cheo xuat phat tu (0,0) --> (15,15)
;-  Tren_Chinh: la duong cheo cung huong, nam phia tren Duong cheo Chinh
;-  Duoi_Chinh: la duong cheo cung huong, nam phia duoi Duong cheo Chinh
;**Truoc tien, kiem tra xem diem sang sau khi nhan E co vuot ra khoi (15,15) hay khong. Neu co thi roi vao 
;truong hop "vuot duong cheo Chinh". Khi do nhay den nhan xu ly truong hop nay.
;**Neu khong xay ra "vuot duong cheo Chinh" thi can kiem tra xem diem sang sau khi nhan E co vuot duong
;cheo tren "Tren_Chinh" hay vuot duong cheo duoi "Duoi_Chinh" hay khong? Neu co thi nhay den nhan xu ly 
;cac truong hop nay.
;**Neu khong xay ra cac truong tren thi sau khi nhan E thi giong nhu nhan to hop hai phim W va D.
;=======================================================================================================
KEY_E:
		INC R12						;tang y
		MOV R16,R12					
		CPI R16,16					;kiem tra xem y=16?
		BRCC OVER_W_15_E			;neu co thi tien hanh kiem tra x=16?
		RCALL KEY_W					;neu khong thi khong xay ra truong hop E vuot duong cheo Chinh
		INC R13
		RCALL KEY_D
		RJMP NEVER_OVER_15_15_E		;nhay den nhan thucj hien phim nhan E truong hop khong vuot duong cheo Chinh
OVER_W_15_E:						;kiem tra xem x=16?
		RCALL KEY_W
		INC R13
		MOV R16,R13
		CPI R16,16
		BRCC OVER_15_15_E			;neu x=16 thi tien hanh nhay den nhan OVER_15_15_E xu ly truong hop vuot duong cheo Chinh
		RCALL KEY_D					;neu x<16 thi thuc hien chuong trinh truong hop E khong vuot duong cheo Chinh

		//thuc hien nhan phim E khi E khong thuoc truong hop vuot duong cheo Chinh
NEVER_OVER_15_15_E:					
		MOV R16,R12
		CPI R16,0					;kiem tra xem co vuot duong cheo Tren_Chinh hay khong?
		BRNE CHECK_E_OVER_ROW		;neu khong thi kiem tra xem co vuot duong cheo Duoi_Chinh hay khong?
		
		//truong hop vuot duong cheo Tren_Chinh
		//sau khi vuot thi toa do cua diem anh sang la Point(0,y)
		PUSH R13					;cat gia tri x len stack (*luu y: x luc nay da +1 so voi vi tri vuot)		
		RCALL SETUP_MATRIX			;reset lai Matrix led
		LDI R16,16					
		POP R13
		SUB R16,R13					;lay vi tri y=15-(x-1)
SET_Y_E:							;tien hanh set y
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_E
		CLR R13						;set x=0
		RJMP EXIT_OPTION_KEY_E		;nhay den nhan thoat

CHECK_E_OVER_ROW:
		MOV R16,R13
		CPI R16,0					;kiem tra xem co vuot duong cheo Duoi_Chinh hay khong?
		BRNE EXIT_OPTION_KEY_E		;neu khong thi nhay den nhan thoat

		//truong hop vuot duong cheo Duoi_Chinh
		//sau khi vuot thi toa do cua diem anh sang la Point(x,0)
		PUSH R12					;cat gia tri y len stack (*luu y: y luc nay da +1 so voi vi tri vuot)
		RCALL SETUP_MATRIX			;reset lai Matrix led
		LDI R16,16
		POP R12
		SUB R16,R12					;lay vi tri x=15-(y-1)
SET_X_E:							;tien hanh set x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_E
		CLR R12						;set y=0
		RJMP EXIT_OPTION_KEY_E		;nhay den nhan thoat

		//truong hop E vuot duong cheo Chinh
		//can set Point(0,0) nen chi can reset lai Matrix led la duoc
OVER_15_15_E:
		RCALL SETUP_MATRIX
EXIT_OPTION_KEY_E:					;thoat khoi phim nhan E
		RET
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO DUONG CHEO KHI NHAN PHIM (C)
;=======================================================================================================
;**Mot so khai niem duoc su dung trong CTC:
;-  Duong cheo phu nguoc: la duong cheo xuat phat tu (0,15) --> (15,0)
;-  Nguoc_Tren_Phu: la duong cheo cung huong, nam phia tren Duong cheo phu nguoc
;-  Nguoc_Duoi_Phu: la duong cheo cung huong, nam phia duoi Duong cheo phu nguoc
;**Truoc tien, kiem tra xem diem sang sau khi nhan C co vuot ra khoi (15,0) hay khong. Neu co thi roi vao 
;truong hop "vuot Duong cheo phu nguoc". Khi do nhay den nhan xu ly truong hop nay.
;**Neu khong xay ra "vuot Duong cheo phu nguoc" thi can kiem tra xem diem sang sau khi nhan C co vuot duong
;cheo "Nguoc_Tren_Phu" hay vuot duong cheo "Nguoc_Duoi_Phu" hay khong? Neu co thi nhay den nhan xu ly 
;cac truong hop nay.
;**Neu khong xay ra cac truong tren thi sau khi nhan C thi giong nhu sau khi Reset Matrix led thi lan luot
;nhan to hop hai phim W va D voi so luong thich hop.
;=======================================================================================================
KEY_C:
		INC R13							
		MOV R16,R13	
		CPI R16,16						;kiem tra xem x=16?
		BRCC OVER_D_15_C				;neu x=16 thi nhay sang OVER_D_15_C de tiep tuc kiem tra
		RCALL KEY_D						;neu x<=15 thi thuc hien nhan C nhu binh thuong
		RCALL KEY_S
		RJMP NEVER_OVER_15_0_C			

OVER_D_15_C:							;kiem tra y
		RCALL KEY_D
		MOV R16,R12										
		CPI R16,0						;kiem tra xem y=0?
		BREQ OVER_15_0_C				;neu co thi nhay den nhan de thuc hien truong hop vuot Duong cheo phu nguoc
		RCALL KEY_S						;neu y>=1 thi thuc hien nhan C nhu binh thuong

		//thuc hien nhan phim C khi khong thuoc truong hop vuot Duong cheo phu nguoc
NEVER_OVER_15_0_C:
		MOV R16,R12
		CPI R16,15						;kiem tra xem co vuot duong cheo Nguoc_Duoi_Phu hay khong?
		BRNE CHECK_C_OVER_ROW			;neu khong thi kiem tra xem co vuot duong cheo Nguoc_Tren_Phu hay khong?

		//truong hop vuot duong cheo Nguoc_Duoi_Phu
		//sau khi vuot thi toa do cua diem anh sang la Point(0,y)
		PUSH R13						;cat gia tri x len stack (*luu y: x luc nay da +1 so voi vi tri vuot)
		RCALL SETUP_MATRIX				;reset Matrix led
		POP R13
		MOV R16,R13
		DEC R16							;dat y=x-1
SET_Y_C:								;thuc hien set y
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_C
		CLR R13							;set x=0
		RJMP EXIT_OPTION_KEY_C			;nhay den nhan thoat
		
CHECK_C_OVER_ROW:						
		MOV R16,R13		
		CPI R16,0						;kiem tra xem co vuot duong cheo Nguoc_Tren_Phu hay khong?
		BRNE EXIT_OPTION_KEY_C			;neu khong thi nhay den nhan thoat

		//truong hop vuot duong cheo Nguoc_Tren_Phu
		//sau khi vuot thi toa do cua diem anh sang la Point(x,15)
		PUSH R12						;cat gia tri y len stack (*luu y: y luc nay da -1 so voi vi tri vuot)
		RCALL SETUP_MATRIX				;reset Matrix led
		POP R12							
		MOV R16,R12
		INC R16							;dat x=y+1
SET_X_C:								;tien hanh set x
		RCALL KEY_D						
		INC R13
		DEC R16
		BRNE SET_X_C
		LDI R16,15
		CLR R12				
SET_Y_C_15:								;set y=15
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_Y_C_15
		RJMP EXIT_OPTION_KEY_C			;nhay den nhan thoat
		 
		//truong hop C vuot Duong cheo phu nguoc 
		//can set Point(0,15)
OVER_15_0_C:
		RCALL SETUP_MATRIX
		LDI R16,15
SET_0_15_C:
		RCALL KEY_W
		INC R12
		DEC R16
		BRNE SET_0_15_C
EXIT_OPTION_KEY_C:						;thoat khoi nut nhan C
		RET
;=======================================================================================================
;CTC DICH CHUYEN DIEM SANG THEO DUONG CHEO KHI NHAN PHIM (C)
;=======================================================================================================
;**Mot so khai niem duoc su dung trong CTC:
;-  Duong cheo phu nguoc: la duong cheo xuat phat tu (0,15) --> (15,0)
;-  Nguoc_Tren_Phu: la duong cheo cung huong, nam phia tren Duong cheo phu nguoc
;-  Nguoc_Duoi_Phu: la duong cheo cung huong, nam phia duoi Duong cheo phu nguoc
;**Truoc tien, kiem tra xem diem sang sau khi nhan C co vuot ra khoi (15,0) hay khong. Neu co thi roi vao 
;truong hop "vuot Duong cheo phu nguoc". Khi do nhay den nhan xu ly truong hop nay.
;**Neu khong xay ra "vuot Duong cheo phu nguoc" thi can kiem tra xem diem sang sau khi nhan C co vuot duong
;cheo "Nguoc_Tren_Phu" hay vuot duong cheo "Nguoc_Duoi_Phu" hay khong? Neu co thi nhay den nhan xu ly 
;cac truong hop nay.
;**Neu khong xay ra cac truong tren thi sau khi nhan C thi giong nhu sau khi Reset Matrix led thi lan luot
;nhan to hop hai phim W va D voi so luong thich hop.
;=======================================================================================================
KEY_Q:
		MOV R16,R13										
		CPI R16,0					;kiem tra xem x=0?
		BREQ OVER_A_0_Q				;neu x=0 thi nhay sang OVER_A_0_Q de kiem tra tiep
		RCALL KEY_A					;neu x>=1 thi thuc hien nhan phim Q nhu binh thuong	
		INC R12
		RCALL KEY_W	
		RJMP NEVER_OVER_0_15_Q

OVER_A_0_Q:							
		RCALL KEY_A
		INC R12
		MOV R16,R12										
		CPI R16,16					;kiem tra y=16?
		BRCC OVER_0_15_Q			;neu y=16 thi roi vao truong hop vuot Duong cheo phu
		RCALL KEY_W					;neu y<=15 thi thuc hien nhan phim Q nhu binh thuong	

		//thuc hien nhan phim Q khi khong thuoc truong hop vuot Duong cheo phu
NEVER_OVER_0_15_Q:
		MOV R16,R13
		CPI R16,15					;kiem tra xem co vuot duong cheo Duoi_Phu hay khong?
		BRNE CHECK_Q_OVER_COL		;neu khong thi kiem tra xem co vuot duong cheo Duoi_Phu hay khong?

		//truong hop vuot duong cheo Duoi_Phu
		//sau khi vuot thi toa do cua diem anh sang la Point(x,0)
		PUSH R12					;cat gia tri y len stack (*luu y: y luc nay da +1 so voi vi tri vuot)
		RCALL SETUP_MATRIX			;reset Matrix led
		POP R12
		MOV R16,R12
		DEC R16						;dat x=y-1
SET_X_Q:							;tien hanh set x
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Q
		CLR R12						;set y=0
		RJMP EXIT_OPTION_KEY_Q		;nhay den nhan thoat
		
CHECK_Q_OVER_COL:						
		MOV R16,R12
		CPI R16,0					;kiem tra xem co vuot duong cheo Tren_Phu hay khong?
		BRNE EXIT_OPTION_KEY_Q		;neu khong thi nhay den nhan thoat

		//truong hop vuot duong cheo Tren_Phu
		//sau khi vuot thi toa do cua diem anh sang la Point(15,y)
		PUSH R13					;cat gia tri x len stack (*luu y: x luc nay da -1 so voi vi tri vuot)
		RCALL SETUP_MATRIX
		POP R13
		MOV R16,R13
		INC R16						;dat y=x+1
SET_Y_Q:							;tien hanh set y
		RCALL KEY_W					
		INC R12
		DEC R16
		BRNE SET_Y_Q
		LDI R16,15
		CLR R13							
SET_X_Q_15:							;set x=15
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_X_Q_15
		RJMP EXIT_OPTION_KEY_Q		;nhay den nhan thoat

		//truong hop C vuot Duong cheo phu 
		//can set Point(15,0)
OVER_0_15_Q:
		RCALL SETUP_MATRIX
		LDI R16,15
SET_15_0_Q:
		RCALL KEY_D
		INC R13
		DEC R16
		BRNE SET_15_0_Q
EXIT_OPTION_KEY_Q:					;thoat khoi phim nhan		
		RET	
;============================================================================================
;CTC KHOI DONG MATRIX LED 16X16 
;============================================================================================
;Matrix led A có toa do 4 dinh lan luot la (0,0),(7,0),(0,7),(7,7)
;Matrix led B có toa do 4 dinh lan luot la (8,0),(15,0),(0,7),(15,7)
;Matrix led C có toa do 4 dinh lan luot la (0,8),(7,8),(0,15),(7,15)
;Matrix led D có toa do 4 dinh lan luot la (8,8),(15,8),(8,15),(15,15)
;Set tat ca chan GND cua cac Matrix led A-D o muc tich cuc cao
;Set mot diem sang o goc toa do (0,0)
;============================================================================================
SETUP_MATRIX:
		//clear cac chan nguon cua cac Matrix led 
		SBI PORTA,6			;cho phep 573_row
		LDI R20,16			;so luong chan Power(P)
		PUSH R20			;cat vao stack	
		CBI	PORTA,1			;muc thap du lieu cho 595_row_A_B  
LP_CLR_A_B:
		CBI PORTA,0			;tao xung canh len truyen du lieu
		SBI PORTA,0			;ra chan cua thanh ghi dich 
		CBI PORTA,2			;595_row_A_B
		SBI PORTA,2			
		DEC R20				;giam bien dem so chan Power(P)
		BRNE LP_CLR_A_B		;neu chua Clear het thi lap lai
		POP R20				;lay so luong chan Power(P) xuong
		CBI	PORTA,4			;muc thap du lieu cho 595_row_C_D 
LP_CLR_C_D:
		CBI PORTA,3			;tao xung canh len truyen du lieu
		SBI PORTA,3			;ra chan cua thanh ghi dich 
		CBI PORTA,5			;595_row_C_D
		SBI PORTA,5	
		DEC R20				;giam bien dem so chan Power(P)		
		BRNE LP_CLR_C_D		;neu chua Clear het thi lap lai
		CBI PORTA,6			;khong cho phep 573_row
		
		//set cac chan GND cua cac Matrix led
		SBI PORTA,7			;cho phep 573_col
		LDI R20,16			;so luong chan GND
		PUSH R20			;cat vào stack	
		SBI	PORTA,1			;muc cao du lieu cho 595_col_A_C  
LP_SET_A_C:
		CBI PORTA,0			;tao xung canh len truyen du lieu
		SBI PORTA,0			;ra chan cua thanh ghi dich 
		CBI PORTA,2			;595_col_A_C
		SBI PORTA,2			
		DEC R20				;giam bien dem so chan GND
		BRNE LP_SET_A_C		;neu chua Set het thi lap lai
		POP R20				;lay so luong chan GND xuong
		SBI	PORTA,4			;muc cao du lieu cho 595_col_B_D 
LP_SET_B_D:
		CBI PORTA,3			;tao xung canh len truyen du lieu
		SBI PORTA,3			;ra chan cua thanh ghi dich 
		CBI PORTA,5			;595_col_B_D
		SBI PORTA,5	
		DEC R20				;giam bien dem so chan GND		
		BRNE LP_SET_B_D		;neu chua Set het thi lap lai

		//set mot diem anh sang tai toa do (0,0)
		//set muc tich cuc thap cho chan GND toa do (x,0)
		CBI	PORTA,1			;muc thap du lieu cho 595_col_A_C
		CBI PORTA,0			;tao xung canh len truyen du lieu
		SBI PORTA,0			;595_col_A_C
		CBI PORTA,2			
		SBI PORTA,2
		CBI PORTA,0	
		CBI PORTA,7			;không cho phép 573_col

		//set muc tich cao cho chan P toa do (0,y)
		CLR R16				;clear cac chân PA truoc khi ket noi voi 
		OUT PORTA,R16		;595_row_A_B
		SBI PORTA,6			;cho phep 573_row_A_B
		SBI	PORTA,1			;muc cao du lieu cho 595_row_A_B
		CBI PORTA,0			;tao xung canh len truyen du lieu
		SBI PORTA,0			;595_row_A_B
		CBI PORTA,2		
		SBI PORTA,2
		CBI PORTA,0
		CBI PORTA,6			;không cho phép 573_row_A_B
		//clear cac thanh ghi su dung trong viec dem vi tri (location)
		CLR R10				;clear thanh ghi dem toa do hang(y) trong 1 matrix co gia tri tu 0->8
		CLR R11				;clear thanh ghi dem toa do cot(x) trong 1 matrix co gia tri tu 0->8
		CLR R12				;clear thanh ghi dem toa do hang(y) trong 4 matrix co gia tri tu 0->15
		CLR R13				;clear thanh ghi dem toa do cot(x) trong 4 matrix co gia tri tu 0->15
		CLR R0				;clear thanh ghi dem toa do cua matrix (Y) co gia tri tu 0->2	
		CLR R1				;clear thanh ghi dem toa do cua matrix (X) co gia tri tu 0->2
		RET	
;--------------------------------------------------
DELAY_500MS:	
		LDI R19,5			;0.5s=5*100ms
LP3:	LDI R18,100			;100ms=100*1ms	
LP2:	LDI R17,200			;1ms=5*200
LP1:	LDI R16,8			;5*8=40MC -> 5us	
LP:		NOP
		NOP
		DEC R16
		BRNE LP
		DEC R17
		BRNE LP1
		DEC R18
		BRNE LP2
		DEC R19
		BRNE LP3
		RET


