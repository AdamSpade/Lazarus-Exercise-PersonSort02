program DevSandbox;

{$mode ObjFPC}{$H+}

uses
  crt,
  fgl,
  StrUtils,
  SysUtils,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };


type
  TPersonClass = class(TObject)
    firstName : String;
    lastName : String;
    address : String;
    city : String;
    state: String;
    age : String;
  private
  public
  end;

  TPersonList = specialize TFPGObjectList<TPersonClass>;

const
  Input_File = 'InputData.txt';
  Output_File = 'OutputData.txt';

var
  newPersonObjList : TPersonList;
  newPersonObj: TPersonClass;
  inputList   : TStringList;
  outputList  : TStringList;
  myStringList: TStringList;
  exampleLine : String;
  exampleLine2: String;
  line        : String;
  textFileIn  : TextFile;
  textFileOut : TextFile;
  itmIdx      : Integer;

begin
  //exampleLine:= '"Dave","Smith","123 main st.","seattle","wa","43"';
  //exampleLine2:= '"George","Brown","345 3rd Blvd., Apt. 200","Seattle","WA","18"';

  { Creates the needed TSTRINGLISTs }
  inputList:= TStringList.Create;
  outputList:= TStringList.Create;
  myStringList:= TStringList.Create;
  newPersonObj:= TPersonClass.Create;
  newPersonObjList:= TPersonList.Create;

  try
    inputList.LoadFromFile(Input_File);              // Loads inputfile
    for itmIdx:= 0 to inputList.Count-1 do begin     // Starts forloop
      line:= inputList.Strings[itmIdx];              // Assigns string to line var

      myStringList.CommaText:= line.Replace('.,', '.').ToUpper;  // Splits string by comma
      //Write(myStringList[itmIdx], ', ');

      newPersonObj.firstName:= myStringList[0];
      newPersonObj.lastName:= myStringList[1];
      newPersonObj.address:= myStringList[2];
      newPersonObj.city:= myStringList[3];
      newPersonObj.state:= myStringList[4];
      newPersonObj.age:= myStringList[5];

      newPersonObjList.Add(newPersonObj);

      WriteLn('First Name = ', newPersonObj.firstName);
      Writeln('Last Name = ', newPersonObj.lastName);
      WriteLn('Address = ', newPersonObj.address);
      WriteLn('City = ', newPersonObj.city);
      WriteLn('State = ', newPersonObj.state);
      WriteLn('Age = ', newPersonObj.age);
      WriteLn();


      myStringList.SaveToFile(Output_File);
    end;
  finally
    inputList.Free;
    outputList.Free;
    myStringList.Free;
    newPersonObj.Free;
  end;

  //WriteLn('First Name = ', newPersonObj.firstName);
  //Writeln('Last Name = ', newPersonObj.lastName);
  //WriteLn('Address = ', newPersonObj.address);
  //WriteLn('City = ', newPersonObj.city);
  //WriteLn('State = ', newPersonObj.state);
  //WriteLn('Age = ', newPersonObj.age);

  ReadKey;
end.

