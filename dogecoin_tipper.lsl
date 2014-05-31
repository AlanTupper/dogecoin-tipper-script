// dogecoin tipper.lsl
// By Alan Tupper
// MIT License - To the Moooooon!
// Sunday, May 24, 2014
//

// Script expects a Notecard named "Address" containing a Dogecoin address on the first line. 
// When the script is reset, it will delete the card so someone else can take over.

string qr_url = "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=";
string balance_url = "http://dogechain.info/chain/Dogecoin/q/addressbalance/";

string wallet_address = "";
key recipient = NULL_KEY;
string recipient_name = "";

integer menu_listen_handle;
integer menu_chan;
integer display_text = TRUE;
integer display_balance = TRUE;

float balance = 0.0;

key request;


//used by setup state
key user;

// basic validation test for Dogecoin address returns a boolean
integer validate_address(string msg)
{
    integer valid = FALSE;
    if(llStringLength(msg) == 34 && llGetSubString(msg,0,0)=="D"){valid = TRUE;}
    
    return valid;
}

// updates the text display if it's enabled
update_display()
{
    if(display_text)
    {
        string base_msg = "Tip " + recipient_name + " some Ðogecoin!";
        string balance_msg = "";
        integer short_balance = (integer)balance;
    
        if(display_balance){balance_msg = "\nCurrent Balance: " + (string)short_balance ;}
    
        llSetText(base_msg + balance_msg,<0.0,0.0,0.0>,1.0);
    }
}

// send a http request to check the balance of the provided address
check_balance()
{
    string full_url = balance_url + wallet_address;
    request = llHTTPRequest(full_url,[],"");  
}

// send a chat message and menu to the user who touched the object
send_tip_message(key id)
{
    string greeting = "Hi " + llKey2Name(id) + "! ";
    string send_coins = "Send coins to " + wallet_address;
    
    llSay(0,greeting + send_coins);
    menu_listen_handle = llListen(menu_chan,"",id,"QR Code"); 
    llDialog(id,"Need a QR Code?",["QR Code"],menu_chan);    
}

// toggle the display of the address balance and throttle the http requests accordingly
toggle_balance()
{
    display_balance = !display_balance;
 
    float delay = 0.0;       
    if(display_balance){ delay = 30; };
        
    llSetTimerEvent(delay);
}

// toggle the entire text display
toggle_display()
{
    display_text = !display_text;
    if(display_text){update_display();}
    else{llSetText("",<0.0,0.0,0.0>,0.0);}    
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
       check_balance();
       llSetTimerEvent(30.0);
           
    }
   
    listen(integer chn, string n, key id, string msg)
    {
        //parse the menu commands, and react accordingly
        if( msg == "QR Code")
        {
            string url = qr_url + wallet_address;
            
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
        else if( msg == "Test Tip"){send_tip_message(id);}
        else if( msg == "Toggle Balance")
        { 
            toggle_balance();
            update_display();
            llListenRemove(menu_listen_handle);
        }
        else if( msg == "Toggle Text")
        {
            toggle_display();
            llListenRemove(menu_listen_handle);    
        }
        

    }
    
    timer()
    {
        if(request == NULL_KEY){check_balance();}
        else
        {
            llSetTimerEvent(0.0);
            display_balance = FALSE;
        }   
    }
    
    http_response(key rqst, integer stat, list meta, string body)
    {
        if(stat == 200)
        {
            balance = llList2Float(llParseString2List(body,[],[]),0);
            request = NULL_KEY;
            update_display();    
        } 
        else{ llSay(0, "Error: " + (string)stat ); }
    }
   
    touch_start(integer num)
    {
        key toucher = llDetectedKey(0);
        
        //check if we should be sending the configuration menu
        if(toucher == recipient || toucher == llGetOwnerKey(llGetOwner()))
        {
            menu_listen_handle = llListen(menu_chan,"",toucher,""); 
            
            string config = "Configured to: " + recipient_name +"\n" + wallet_address;
            list options = ["Reset","Test Tip","Toggle Balance", "Toggle Text"];
              
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
                state default;   
            }    
        }    
        
    }
}
