program DevSandbox;

{$mode ObjFPC}{$H+}

uses
  crt,
  fgl,
  StrUtils,
  SysUtils,
  Generics.Defaults,
  Generics.Collections,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };

type

  { TPersonClass }

  TPersonObj = class(TObject)
  private
    FfirstName: String;
    FlastName: String;
    Faddress: String;
    Fcity: String;
    Fstate: String;
    Fage: Integer;
    procedure SetfirstName(AValue: String);
    procedure SetlastName(AValue: String);
    procedure Setaddress(AValue: String);
    procedure Setcity(AValue: String);
    procedure Setstate(AValue: String);
    procedure Setage(AValue: Integer);
  public
    property firstName : String read FfirstName write SetfirstName;
    property lastName : String read FlastName write SetlastName;
    property address : String read Faddress write Setaddress;
    property city : String read Fcity write Setcity;
    property state : String read Fstate write Setstate;
    property age : Integer read Fage write Setage;
    function ToString: String; override;
  end;

  TPersonList = TList;



const
  Input_File = 'InputData.txt';
  Output_File = 'OutputData.txt';

var
  newPersonObjList : TPersonList;
  newPersonObj: TPersonObj;
  inputList   : TStringList;
  outputList  : TStringList;
  myStringList: TStringList;
  line        : String;
  itmIdx      : Integer;
  outputFile  : TextFile;


{ Custom sort function to compare and order Person objects }
function SortByFamilyName(Person1, Person2: Pointer): integer;
  begin
    if TPersonObj (Person1).FlastName = TPersonObj(Person2).FlastName then
      Result:= CompareText(TPersonObj (Person1).FfirstName, TPersonObj (Person2).FfirstName)
    else
      Result:= CompareText(TPersonObj (Person1).FlastName, TPersonObj (Person2).FlastName);
  end;

//function TPersonClass.AddNewPersonObjList(

{ Custom ToString Function }
function TPersonObj.ToString: String;
  begin
    Result:= Format('LastName=%s, FirstName=%s, Address=%s, City=%s, State=%s, Age=%d',
             [FlastName, FfirstName, Faddress, Fcity, Fstate, Fage]);
  end;



{ TPersonClass - Setters }
procedure TPersonObj.SetfirstName(AValue: String);
  begin
    if FfirstName=AValue then Exit;
    FfirstName:=AValue;
  end;

procedure TPersonObj.SetlastName(AValue: String);
  begin
    if FlastName=AValue then Exit;
    FlastName:=AValue;
  end;

procedure TPersonObj.Setaddress(AValue: String);
  begin
    if Faddress=AValue then Exit;
    Faddress:=AValue;
  end;

procedure TPersonObj.Setcity(AValue: String);
  begin
    if Fcity=AValue then Exit;
    Fcity:=AValue;
  end;

procedure TPersonObj.Setstate(AValue: String);
  begin
    if Fstate=AValue then Exit;
    Fstate:=AValue;
  end;

procedure TPersonObj.Setage(AValue: Integer);
  begin
    if Fage=AValue then Exit;
    Fage:=AValue;
  end;



{ MAIN }
begin

  { Creates the needed TSTRINGLISTs }
  inputList:= TStringList.Create;
  outputList:= TStringList.Create;
  myStringList:= TStringList.Create;
  newPersonObjList:= TPersonList.Create;

  try
    inputList.LoadFromFile(Input_File);              // Loads inputfile
    for itmIdx:= 0 to inputList.Count-1 do begin     // Starts forloop
      line:= inputList.Strings[itmIdx];              // Assigns string to line var

      { Splits string by comma }
      myStringList.CommaText:= line.Replace('.,', '.').ToUpper;

      { Adds the 6 fields to a new TPersonClass object }
      newPersonObj:= TPersonObj.Create;
      newPersonObj.SetfirstName(myStringList[0]);
      newPersonObj.SetlastName(myStringList[1]);
      newPersonObj.Setaddress(myStringList[2]);
      newPersonObj.Setcity(myStringList[3]);
      newPersonObj.state:= myStringList[4];
      newPersonObj.age:= StrToInt(myStringList[5]);

      { Adds the TPersonObj object to TPersonList }
      newPersonObjList.Add(newPersonObj);

    end;

    { Call the sort function pass the custom comparator }
    { to order the object list by last name, then first name }
    newPersonObjList.Sort(@SortByFamilyName);

    { Is there a cleaner way to do this? }
    AssignFile(outputFile, Output_File);
    Rewrite(outputFile);
    CloseFile(outputFile);

    { New loop to pull each Person object out of object list}
    for itmIdx:= 0 to newPersonObjList.Count-1 do begin
      newPersonObj:= TPersonObj (newPersonObjList[itmIdx]);  // typecast to TPerson type

      if (newPersonObj.Fage >= 18) then
        begin
          WriteLn('Full Profile: ', newPersonObj.ToString); // Display object for debugging

          { Writes the Person object to text file }
          outputList.LoadFromFile(Output_File);
          outputList.AddStrings(newPersonObj.ToString);
          outputList.SaveToFile(Output_File);
        end;

    end;

  finally
    inputList.Free;
    outputList.Free;
    myStringList.Free;
    newPersonObj.Free;
  end;

  ReadKey;
end.

