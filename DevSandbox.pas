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

  { TPersonObj }
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
    constructor Create(fName, lName, address, city, state: String; age: Integer);
    property firstName : String read FfirstName write SetfirstName;
    property lastName : String read FlastName write SetlastName;
    property address : String read Faddress write Setaddress;
    property city : String read Fcity write Setcity;
    property state : String read Fstate write Setstate;
    property age : Integer read Fage write Setage;
    function ToString: String; override;
  end;

  TPersonList = TList;  // A TList to add objects to


{ Constants - Input & Output text files }
const
  Input_File = 'InputData.txt';
  Output_File = 'OutputData.txt';

{ Variables }
var
  newPersonObjList : TPersonList;
  newPersonObj: TPersonObj;
  inputList   : TStringList;
  outputList  : TStringList;
  myStringList: TStringList;
  line        : String;
  tempName    : String;
  newLine     : String;
  itemIndex   : Integer;
  count       : Integer;
  outputFile  : TextFile;


{ Custom sort function to compare and order Person objects }
{ First by last name, then first name if last name of compared objects is equal }
function SortByLastName(Person1, Person2: Pointer): integer; begin
    if TPersonObj (Person1).FlastName = TPersonObj(Person2).FlastName then
      Result:= CompareText(TPersonObj (Person1).FfirstName, TPersonObj (Person2).FfirstName)
    else
      Result:= CompareText(TPersonObj (Person1).FlastName, TPersonObj (Person2).FlastName);
  end;

{ Custom ToString Function }
function TPersonObj.ToString: String; begin
    Result:= Format('LastName=%s, FirstName=%s, Address=%s, City=%s, State=%s, Age=%d',
             [lastName, firstName, address, city, state, age]);
  end;

{ TPersonObj - Setters }
procedure TPersonObj.SetfirstName(AValue: String); begin FfirstName:=AValue; end;
procedure TPersonObj.SetlastName(AValue: String); begin FlastName:=AValue; end;
procedure TPersonObj.Setaddress(AValue: String); begin Faddress:=AValue; end;
procedure TPersonObj.Setcity(AValue: String); begin Fcity:=AValue; end;
procedure TPersonObj.Setstate(AValue: String); begin Fstate:=AValue; end;
procedure TPersonObj.Setage(AValue: Integer); begin Fage:=AValue; end;

{ TPerson Obj Constructor }
constructor TPersonObj.Create(fName, lName, address, city, state: String;
  age: Integer); begin
  FfirstName:= fName;
  FlastName:= lName;
  Faddress:= address;
  Fcity:= city;
  Fstate:= state;
  Fage:= age;
end;



{ MAIN }
begin

  { Instantiate TstringLists }
  inputList:= TStringList.Create;
  outputList:= TStringList.Create;
  myStringList:= TStringList.Create;
  newPersonObjList:= TPersonList.Create;

  try
    inputList.LoadFromFile(Input_File);              // Loads inputfile
    for itemIndex:= 0 to inputList.Count-1 do begin     // Starts forloop
      line:= inputList.Strings[itemIndex];              // Assigns string to line var

      { Splits string by comma }
      myStringList.CommaText:= line.Replace('.,', '.').ToUpper;

      { Construct new TPersonObj object and populate its 6 property fields }
      { with the indexes from myStringList }
      newPersonObj:= TPersonObj.Create(
      myStringList[0], myStringList[1],
      myStringList[2], myStringList[3],
      myStringList[4], StrToInt(myStringList[5]));

      { Adds the TPersonObj object to TPersonList }
      newPersonObjList.Add(newPersonObj);

    end;

    { Call the sort function pass the custom comparator }
    { to order the object list by last name, then first name }
    newPersonObjList.Sort(@SortByLastName);


    { Is there a cleaner way to do this? }
    AssignFile(outputFile, Output_File);
    Rewrite(outputFile);
    CloseFile(outputFile);

    { Initialize variables used in the upcoming loop }
    tempName:='';
    newLine:='';
    count:=0;

    { New loop to pull each Person object out of object list}
    { and print the object to a text file }
    for itemIndex:= 0 to newPersonObjList.Count-1 do begin
      newPersonObj:= TPersonObj (newPersonObjList[itemIndex]);  // typecast to TPerson type

      { Checks if new object has a new last name not already assigned to tempName }
      { If no, assign it to tempName. Else move on}
      if tempName <> newPersonObj.lastName then begin
         tempName:= newPersonObj.lastName;
         outputList.LoadFromFile(Output_File);

         { If current count is above 0 then writes count to file }
         if count > 0 then begin
             outputList.AddStrings('Family Member(s): ' + IntToStr(count));
             outputList.Add(newLine);
           end;

         { Writes a header for last name to the file and resets family member count }
         outputList.AddStrings(newPersonObj.lastName + ' HOUSEHOLD');
         outputList.SaveToFile(Output_File);
         count:=0;
        end;

      { If age of person is over 18, writes the object to file }
      { Family member count increases by 1 }
      if (newPersonObj.age >= 18) then begin
          outputList.LoadFromFile(Output_File);
          outputList.AddStrings(newPersonObj.ToString);
          outputList.SaveToFile(Output_File);

          count:= count + 1;
          //WriteLn('Full Profile: ', newPersonObj.ToString); // Display object for debugging
        end;

    end;
      { Add family member count to final records of text file }
      outputList.LoadFromFile(Output_File);
      outputList.AddStrings('Family Member(s): ' + IntToStr(count));
      outputList.SaveToFile(Output_File);

  finally
    inputList.Free;
    outputList.Free;
    myStringList.Free;
    newPersonObj.Free;
  end;

  //ReadKey;
end.

