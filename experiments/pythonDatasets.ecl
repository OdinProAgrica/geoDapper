IMPORT python3;

recIn := {INTEGER anint, STRING uid;};  //NOTE, THIS ALL GETS LOWERCASED WHEN IT GOES TO PYTHON!!!!!!
recOut := {INTEGER anint, STRING uid; };
testRec := {STRING test;};

testTable := DATASET([{155,'aap'}, {245,'baap'}, {987,'cape'}, {987,'cap'}, {123,'cap'}], recIn);   

LINKCOUNTED DATASET(recOut) runTransform(DATASET(recIn) recs) := EMBED(Python3)

  for rec in recs:
    newInt = rec.anint + 1
    yield (newInt, rec.uid)
				
ENDEMBED;

outDF := runTransform(testTable);
outDF;










