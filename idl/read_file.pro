;/home/ishii/lib/misc/read_file.pro 	by TTI 2002.07.23

function read_file,ffi,dbl=dbl,str=str

;USAGE	IDL> a=read_file('input_file')
;	double:	aa=read_file('input_file',/dbl,/str)
;

on_error,2
close,1

spawn,"wc "+ffi+" | awk '{print $1}' ",nn_2
spawn,"wc "+ffi+" | awk '{print $2}' ",nn

nn_2=float(nn_2)

if nn_2(0) ne 0 then begin
nn=float(nn)
nn_1=nn/nn_2

case 1 of 
n_elements(dbl) ne 0 : a=dblarr(nn_1(0),nn_2(0)) 
n_elements(str) ne 0 : a=strarr(1,nn_2(0))
else : a=fltarr(nn_1(0),nn_2(0))
endcase

openr,1,ffi
readf,1,a
close,1

endif else a='No data'

return,a

end
