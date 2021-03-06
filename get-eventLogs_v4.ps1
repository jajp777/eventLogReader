
$sb = {

    Try { 
        # Uncomment $ID variable based on which Windows event ID; TODO: create seperate functions for Event ID groups; event IDs with the same schema can be grouped in the same array
        $ID = @(4634,4624) # Logon, Logoff
        #$ID = @(4688) # New process creation
        #$ID = @(4648,552) # runas command
        #$ID = @(4672) # admin rights
        #$ID = @(106) # task scheduled; did not work in lab
        #$ID = @(200) # task executed; did not work in lab
        #$ID = @(201) # task completed; did not work in lab
        #$ID = @(141) # task removed; did not work in lab
        #$ID = @(4698,602) # scheduled task creation; did not work in lab
        #$ID = @(601,4697) # service creation; did not work in lab
        #$ID = @(528,592) # successful/failed logon; did not work in lab
        #$ID = @(5140) # network share; did not work in lab
        $then = (Get-Date).AddHours(-1)  # AddHours function subtracts X hour from current time
        $filter = @{Logname="Security";Id=$ID;StartTime=$then}           
        $Events = Get-WinEvent -ComputerName localhost -FilterHashtable $filter -ErrorAction Stop            
            
        ForEach ($Event in $Events) {            
            # Convert the event to XML            
            $eventXML = [xml]$Event.ToXml()            
            # Iterate through each one of the XML message properties            
            For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {            
                # Append these as object properties            
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'           
            }            
        }            
            
        # $Events | Select-Object -Property NewProcessName | Out-Default  # Only selects process field i.e. (dllhost.exe)
        $Events | Select-Object *  # selects all properties of object     
    }            
    Catch {            
        If ($_.Exception -like "*No events were found that match criteria*") {            
            Write-Warning "[$(hostname)] No events found" # TODO: create log file with failed event ID, computername, time, etc           
        } Else {            
            $_            
        }            
    }            
                
}            

#$computers = "home-dc1"
$computers = Get-Content C:\Users\asoa\Desktop\computers.txt # creats array from list of computers from file; TODO: consider using Get-ADComputer

foreach ($computer in $computers) {
    if (Test-Connection -ComputerName $computer -Count 1 -ea 0) {
        #Invoke-Command -ScriptBlock $sb -ComputerName $computer | Out-GridView
        Invoke-Command -ScriptBlock $sb -ComputerName $computer | Export-Csv C:\Users\asoa\Desktop\$computer.csv  
    }
}          