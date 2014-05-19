// dogecoin tipper.lsl
// By Alan Tupper
// MIT License - To the Moooooon!
// Sunday, May 18, 2014

string base_url = "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=";
string wallet_address = "";
key recipient = NULL_KEY;
string recipient_name = "";

integer validate_address(string msg)
{
    integer valid = FALSE;
    if(llStringLength(msg) == 34 && llGetSubString(msg,0,0)=="D"){valid = TRUE;}
    
    return valid;
}

default
{
    on_rez(integer start)
    {
        llResetScript();
    }
    
    state_entry()
    {
       if(wallet_address == ""){state setup;}
       
       string tip_msg = "Tip " + recipient_name + " some Dogecoins!";
       llSetText(tip_msg,<0.0,0.0,0.0>,1.0);
       llListen(98,"",NULL_KEY,"reset");     
    }
   
    listen(integer c, string n, key id, string m)
    {
        if(id == recipient || id == llGetOwnerKey(llGetOwner())){llResetScript();}
    }
   
    touch_start(integer num)
    {
        key toucher = llDetectedKey(0);
        string url = base_url + wallet_address;
        
        string pay_msg = "Pay " + recipient_name + " with Dogecoin!";
        llLoadURL(toucher,recipient,url);
    }
}

state setup
{
    state_entry()
    {
        string setup_msg = "Touch to set me up!";
        llSetText(setup_msg,<0.0,0.0,0.0>,1.0);
        
    }
    
    touch_start(integer num)
    {
       key toucher = llDetectedKey(0);
       string setup_msg = "Set your wallet address by typing /98 YourDogecoinAddressHere";      
       llSay(0,setup_msg);
       llListen(98,"",toucher,"");
    }
   
   listen(integer c,string n,key id, string msg)
   {
       if (validate_address(msg))
       {
           wallet_address = msg;
           recipient = id;
           recipient_name = llKey2Name(id);
           llSay(0,"Setup Complete!");
           state default;
          
       } else
       { llSay(0,"Invalid Address, please try again."); }
   }
}

