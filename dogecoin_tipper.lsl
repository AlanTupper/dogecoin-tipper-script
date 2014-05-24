// dogecoin tipper.lsl
// By Alan Tupper
// MIT License - To the Moooooon!
// Sunday, May 24, 2014
//

// Script expects a Notecard named "Address" containing a Dogecoin address on the first line. 
// When the script is reset, it will delete the card so someone else can take over.

string base_url = "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=";
string wallet_address = "";
key recipient = NULL_KEY;
string recipient_name = "";

integer menu_listen_handle;
integer menu_chan;

//used by the setup
key request;
key user;

integer validate_address(string msg)
{
    integer valid = FALSE;
    if(llStringLength(msg) == 34 && llGetSubString(msg,0,0)=="D"){valid = TRUE;}
    
    return valid;
}

send_tip_message(key id)
{
    string send_coins = "Send coins to " + wallet_address;
    string greeting = "Hi " + llKey2Name(id) + "! ";
    llSay(0,greeting + send_coins);
    menu_listen_handle = llListen(menu_chan,"",id,"QR Code"); 
    llDialog(id,"Need a QR Code?",["QR Code"],menu_chan);    
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
           
    }
   
    listen(integer chn, string n, key id, string msg)
    {
        if( msg == "QR Code")
        {
            string url = base_url + wallet_address;
            
            string pay_msg = "QR Code for the Dogecoin address of  " + recipient_name;
            llLoadURL(id,pay_msg,url);
            llListenRemove(menu_listen_handle);
        }
        else if( msg == "Reset")
        {
            integer num = llGetInventoryNumber(INVENTORY_NOTECARD);
        
            while (num) 
            {
                llRemoveInventory(llGetInventoryName(INVENTORY_NOTECARD, num - 1));
                --num;
            }
            llResetScript();
        }
        else if( msg == "Test Tip"){send_tip_message(id);};
        

    }
   
    touch_start(integer num)
    {
        key toucher = llDetectedKey(0);
        
        if(toucher == recipient || toucher == llGetOwnerKey(llGetOwner()))
        {
            menu_listen_handle = llListen(menu_chan,"",toucher,""); 
            
            string config = "Configured to: " + recipient_name +"\n" + wallet_address;
            
            list options = ["Reset","Test Tip"];
              
            llDialog(toucher,config,options,menu_chan);   
        }
        else
        {
            send_tip_message(toucher);     
        }
    }
}

state setup
{

    state_entry()
    {
        string setup_msg = "Touch to set me up.";
        llSetText(setup_msg,<0.0,0.0,0.0>,1.0);
        menu_chan = (integer)llFrand(-9800.0)-1;
    }
    
    touch_start(integer n)
    {
        user = llDetectedKey(0);
        request = llGetNotecardLine("Address",0);     
    }    
    
    dataserver(key q, string data)
    {
        if(q == request && data != EOF)
        {
            if(validate_address(data))
            {
                wallet_address = data;
                recipient = user;
                recipient_name = llKey2Name(user);
                llSay(0,"Setup Complete! Address: " + wallet_address);
                state default;   
            }    
        }    
        
    }
}
