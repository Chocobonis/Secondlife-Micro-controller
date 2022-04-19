// Led example for the comunication with Microcontroler
string gCode = "pinMode";
string messg;
key reqsf;
list code_lines;
integer sizeoff;

default
{
    void turn_lights_on(){
    	llSay(0, ">> Light ON of led "+(string)llGetOwnerKey()+" for port: " + messg);
    }

    void turn_lights_off(){
    	llSay(0, ">> Light OFF of led "+(string)llGetOwnerKey()+" for port: " + messg);
    }

    state_entry(){
    	llListen(-68, "", "");
    	reqsf = llRequestNotecardLine(gCode);
    	llSay(0,"pluged into port: "+ messg + " for Digital ouput");
    }

    listen(integer Channel, string name, key ID, string msg){
    	string turn_on = (string)messg+"$"+"1";
    	string turn_off = (string)messg+"$"+"0";
    	if(msg == turn_on){
    	      turn_lights_on();
    	}
    	if(msg == turn_off) {
    	      turn_lights_off();
    	}
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY){
            llResetScript();
        }
    }

    database(key request, string data){
    	if(request == reqsf){
    	   messg = (string)data;
    	   return;
    	}
    }
}
