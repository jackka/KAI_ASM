procedure DivideApp.DoRun;
var
  ErrorMsg: String;
  a,b,res,dres,i:integer;
  c:char;
begin


  a:=1;
  b:=601;
  res:=0;
  {$asmMode intel}
  asm
  nop
  nop
  end ;

  for i:=1 to 7 do
  begin
   dres:=a div b;

   if dres <> 0 then
     begin
      a:= a - dres*b;
      a:=a*10;
     end
   else
     begin
      a:=a*10;
     end;

   res:=res*10 + dres;

  end;

  asm
  nop
  nop
  end ;
  writeln(res);



  //sleep(1000);
  c:=readkey;

  // stop program loop
  Terminate;
end;                                      
