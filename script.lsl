integer Neof = 0;
string gCode = "code";
integer Ptr_ln = 1;
key num_l;
key cod_req;
integer sizeoff;
list Digital_ports;
list Analog_ports;
list Code_lines;
integer tmp_ptr = 0;
integer return_val = 0;
list def_vars;
list eab_stack;
integer eab_ptr;
integer debugmode = 0;

string GET(list ARRAY,list KEY) {
   if(!llGetListLength(KEY)>1) {
      return "-1";
   }
   integer position;
   do {
       position = llListFindList(ARRAY, KEY);
       if(position%2 && ~position && position) {
           ARRAY = llDeleteSubList(ARRAY,0,position);
       } 
   } while (~position && position%2);
   if(~position) {
       return llList2String(ARRAY,position+1);
   } else {
       return "0";
   } 
}

list PUT(list ARRAY,list KEY, list VALUE) {
   if(llGetListLength(KEY)>1 || llGetListLength(VALUE)>1) {
       return [-1];
   }  
   integer position = llListFindList(ARRAY, KEY);
   list helparray = [];
   do {
       if(!~position) { 
           ARRAY += KEY;
           ARRAY += VALUE;
           return helparray + ARRAY;
       }       
       if(position%2 && ~position && position) {
           helparray += llList2List(ARRAY,0,position);
           ARRAY = llDeleteSubList(ARRAY,0,position);
           position = llListFindList(ARRAY, KEY);     
       } 
   } while (position%2);
   ARRAY = llListReplaceList(ARRAY, VALUE, position + 1, position + 1);
   return helparray + ARRAY;   
}

list ERASE(list ARRAY,list KEY) {
   if(!llGetListLength(KEY)>1) {
       return [-1];
   }
   integer position = llListFindList(ARRAY, KEY);
   list helparray = [];
   do {
       if(!~position) { 
           return helparray + ARRAY;
       }    
        
       if(position%2 && ~position && position) {
           helparray += llList2List(ARRAY,0,position);
           ARRAY = llDeleteSubList(ARRAY,0,position);
           position = llListFindList(ARRAY, KEY);     
       } 
   } while (position%2);
   ARRAY = llDeleteSubList(ARRAY,position, position + 1);  
   return helparray + ARRAY;   
}

default
{
    state_entry(){
        Digital_ports = [];
        Analog_ports = [];
        Code_lines = [];
        Ptr_ln=1;
        llSetText("Bonirix Chip>> Waiting...",<1,0,1>,0.5);
        cod_req = llGetNotecardLine(gCode, tmp_ptr); 
        num_l = llGetNumberOfNotecardLines(gCode);
        integer i = 0;
        for(i = 0; i < 100; i++){
            Digital_ports = Digital_ports + 0;
            Analog_ports = Analog_ports + 0;
        }
        llSay(0, "******************");
        llSay(0, "* BONIRIX SYSTEM *");
        llSay(0, "******************");
        llListen(150, "", "", "");
    }
    
    touch_start(integer touch_act)
    {
        llSetText("Bonirix Chip>> Starting...",<0,1,0>,1); 
        Neof = 0; 
        Ptr_ln = 1;
        debugmode = 0;
        eab_stack = [];
        def_vars  = [];
        eab_ptr = 0;
        return_val = 0;
        llSay(0, ">> Lines detected:"+(string)sizeoff );
        while(Neof == 0){
           //llSay(0, "fetch: " + llList2String(Code_lines, Ptr_ln));
           string rd_ptr = llList2String(Code_lines, Ptr_ln);
           list instr_sp = llParseString2List(rd_ptr, [" "], []);
           /*
           ===========================================================================
           = HERE STARTS THE PART THAT UNDERSTANDS AND EXECUTES INSTRUCTIONS ON CODE =
           ===========================================================================
           */
           if(llList2String(instr_sp, 0) == "ret"){
               return_val = (integer)llList2String(instr_sp, 1);
               Ptr_ln = sizeoff+1;
           }
           if(llList2String(instr_sp, 0) == "jmp"){
               Ptr_ln = (integer)llList2String(instr_sp, 1)-1;
           }
           if(llList2String(instr_sp, 0) == "mov"){
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [llList2String(instr_sp, 2)]);
               if(debugmode==1){
                llSay(0, "Mov instruction Detected " + llList2String(instr_sp, 1) + 
                " Added " + GET(def_vars, [llList2String(instr_sp, 1)]) );
               }
           }
           if(llList2String(instr_sp, 0) == "wrd"){
                llSay(150, "Digital$Out$" + llList2String(instr_sp, 1) + "$" + llList2String(instr_sp, 2));
           }
           if(llList2String(instr_sp, 0) == "wra"){
                llSay(150, "Analog$Out$" + llList2String(instr_sp, 1) + "$" + llList2String(instr_sp, 2));
           }
           if(llList2String(instr_sp, 0) == "lda"){
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)],
                [(integer)llList2String(Analog_ports, (integer)llList2String(instr_sp, 1))]);
               /*llSay(0,"LDA instruction found: " + GET(def_vars, [llList2String(instr_sp, 1)])
               + " for registry" + llList2String(instr_sp, 1));*/
           }
           if(llList2String(instr_sp, 0) == "ldd"){
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)],
                [(integer)llList2String(Digital_ports, (integer)llList2String(instr_sp, 1))]);
               /*llSay(0,"LDD instruction found: " + GET(def_vars, [llList2String(instr_sp, 1)])
               + " for registry" + llList2String(instr_sp, 1));*/
           }
           
           if(llList2String(instr_sp, 0) == "dbg"){  // ENABLE OR DISABLE DEBUG MODE
               if(llList2String(instr_sp, 1) == "on" || llList2String(instr_sp, 1) == "1" || llList2String(instr_sp, 1) == "true"){
                   debugmode = 1;
               }else{
                   debugmode = 0;    
               }
           }
           
           if(llList2String(instr_sp, 0) == "dly"){  // PAUSE DELAY
               llSleep((float)llList2String(instr_sp, 1));
           }
           /* ==== [ COMPARATION BETWEEN VARIABLES ] ==== */
           if(llList2String(instr_sp, 0) == "cmp"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " == " + (string)variableB);}
               if(variableA == variableB){
                   if(debugmode==1){ llSay(0,"Yes");  }  
               }else{
                   if(debugmode==1){ llSay(0,"No");  }
                    Ptr_ln++;
               }
           }
           
           if(llList2String(instr_sp, 0) == "upr"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " > " + (string)variableB);}
               if(variableA > variableB){
                    if(debugmode==1){llSay(0,"Yes");}  
               }else{
                    if(debugmode==1){llSay(0,"No");}
                    Ptr_ln++;
               }
           }
           
           if(llList2String(instr_sp, 0) == "lwr"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " < " + (string)variableB);}
               if(variableA < variableB){
                    if(debugmode==1){llSay(0,"Yes");}    
               }else{
                    if(debugmode==1){llSay(0,"No");}
                    Ptr_ln++;
               }
           }
           
           /* ====== [COMPARE INSTRUCTIONS END HERE] ===============*/
           /* ====== [MATH AND BYTE INSTRUCTIONS FROM HERE] ========*/
           if(llList2String(instr_sp, 0) == "add"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA + variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " + " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "sub"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA - variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " - " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "mul"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA * variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " * " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "div"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA / variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " / " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "mod"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA % variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " % " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "abs"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               variableA = llAbs(variableB);
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableA]);
               if(debugmode==1){llSay(0,"is ABS| " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           /*======= {END OF ARITMETIC AND START OF BIT OPERAND} ==============*/
           if(llList2String(instr_sp, 0) == "xor"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA ^ variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " XOR " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "shl"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA << variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " << " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "shr"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               integer variableC = variableA >> variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableC]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " >> " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           
           if(llList2String(instr_sp, 0) == "cpy"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               integer variableB = (integer)GET(def_vars, [llList2String(instr_sp, 2)]);
               variableA = variableB;
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)variableA]);
               if(debugmode==1){llSay(0,"is " + (string)variableA + " = " + (string)variableB + " = " + GET(def_vars, [llList2String(instr_sp, 1)]));}
           }
           /*=========== <<END OF NUMERIC OPERATIONS>> ============*/
           /* ---------- <<START OF STACK OPERATIONS>> ------------*/
           if(llList2String(instr_sp, 0) == "push"){
               integer variableA = (integer)GET(def_vars, [llList2String(instr_sp, 1)]);
               string pos = "register" + (string)eab_ptr;
               eab_stack = PUT(eab_stack, [pos], [(string)variableA]);
               if(debugmode==1){llSay(0, "Pushed value: " + GET(eab_stack, [pos]));}
               eab_ptr++; 
           }
           
           if(llList2String(instr_sp, 0) == "pop"){
               if(eab_ptr > 0){
                eab_ptr--;
                string pos = "register" + (string)eab_ptr;
                if(debugmode==1){llSay(0, "Poped value: " + GET(eab_stack, [pos]));}
                eab_stack = ERASE(eab_stack, [pos]);
               }
           }
           
           if(llList2String(instr_sp, 0) == "lds"){
               string pos = "register" + (string)(eab_ptr-1);
               integer rd_eab = (integer)GET(eab_stack, [pos]);
               def_vars = PUT(def_vars, [llList2String(instr_sp, 1)], [(string)rd_eab]);
               if(debugmode==1){
                llSay(0, "loaded stack: " + GET(def_vars,[llList2String(instr_sp, 1)]));
               }
           }
           /* ---------------- [[END OF STACK]] -------------------*/
           // ========================================================================
           if(Ptr_ln > sizeoff){
               Neof=1;
               llSetText("Bonirix Chip>> Task Completed!",<0,1,0>,0.5);
               llSay(0, "Finished with return statement:" + (string)return_val);
               llSay(0, "-----------------------------------");
           } else{
                llSetText("Bonirix Chip>> Reading...",<0,1,0>,0.5);
                Ptr_ln++;
           }
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
            llResetScript();
    }
    
    dataserver(key obj, string dt){
        if(obj == cod_req){
            if(dt != EOF){
             Code_lines += dt;
             //llSay(0,"Compiled: "+(string)tmp_ptr+"| " + dt);
             ++tmp_ptr;
             cod_req = llGetNotecardLine(gCode, tmp_ptr);
            } 
        } 
        
        if (obj == num_l)
        {
            sizeoff = (integer) dt;           
            return;
        }
    }
    listen(integer Channel, string Name, key ID, string msg){
        list sys_req = llParseString2List(msg, ["$"], []);
        if(llList2String(sys_req, 0) == "Digital"){
            if(llList2String(sys_req, 1) == "In"){
                Digital_ports = llListReplaceList(Digital_ports, [ (integer)llList2String(sys_req, 3)],
                (integer)llList2String(sys_req, 2),  (integer)llList2String(sys_req, 2));
                llSay(0,"fetch Dig: " + llList2String(Digital_ports, (integer)llList2String(sys_req, 2)) + " when expected: " + (string)llList2String(sys_req, 3));
            }
        }
        if(llList2String(sys_req, 0) == "Analog"){
            if(llList2String(sys_req, 1) == "In"){
                Analog_ports = llListReplaceList(Analog_ports, [ (integer)llList2String(sys_req, 3)],
                (integer)llList2String(sys_req, 2),  (integer)llList2String(sys_req, 2));
                llSay(0,"fetch An: " + llList2String(Analog_ports, (integer)llList2String(sys_req, 2)) + " when expected: " + (string)llList2String(sys_req, 3));
            }
        }
    }
}

