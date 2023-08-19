*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      License
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/acc_ver.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
# ${DAY1}      2015-06-14
# ${DAY2}      2019-04-01
# ${ph1}         1895590090
# ${ph2}         1020567630
# ${ph3}         1895590091
# ${ph4}         1020567631
# ${ph5}         1895590092
# ${ph6}         1020567632
# ${ph7}         1894490092
# ${ph8}         1021667632
# ${ph9}         1894490093
# ${ph10}        1021667633
# ${email2}      pb.${test_mail}
# ${sTime}         06:00 AM
# ${eTime}	     08:00 AM
# ${longi}            89.524764
# ${latti}            45.259874
# ${longi1}           10.524764
# ${latti1}           80.259874
# ${longi2}           32.524764
# ${latti2}           40.259874
# ${longi3}           50.524764
# ${latti3}           60.259874
# ${longi4}           40.524764
# ${latti4}           10.259874
# ${longi5}           40.524765
# ${latti5}           10.259875      
# ${PUSERNAMETRIAL1}      1888888771
# ${PUSERNAMETRIAL2}      1888888772
# ${PUSERNAMETRIAL3}      1888888773
# ${PUSERNAMETRIAL4}      1888888774
# ${PUSERNAMETRIAL5}	    1888888775
# ${PUSERNAMETRIAL6}	    1888888776
# ${PUSERNAMETRIAL7}      1888888777

# ${PUSERNAMETRIAL8}      1888888778
# ${PUSERNAMETRIAL9}      1888888779
# ${PUSERNAMETRIAL10}     1888888780
# ${PUSERNAMETRIAL11}     1888888781
# ${PUSERNAMETRIAL12}	    1888888782
# ${PUSERNAMETRIAL13}	    1888888783
# ${PUSERNAMETRIAL14}     1888888784

# ${PUSERNAMETRIAL15}      1888888785
# ${PUSERNAMETRIAL16}      1888888786
# ${PUSERNAMETRIAL17}      1888888787
# ${PUSERNAMETRIAL18}      1888888788
# ${PUSERNAMETRIAL19}	     1888888789
# ${PUSERNAMETRIAL20}	     1888888790
# ${PUSERNAMETRIAL21}      1888888791


*** Test Cases ***

Jaldee-TC-Upgrade License Package-1
    [Documentation]  Change Package from Trial to Gold
    # Comment  Trial package have No addon . total 3 adword added. no nothing will remove
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200

*** comment ***
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL1}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL1}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${email2}  customersOnly
    ${resp}=  Create Business Profile  AAAAAA Care  Edathala   Anjali  Thrissur  ${longi}  ${latti}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680020  Puliparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons']}  []
    
    comment  add adword

    ${resp}=  Add Adword  suvraz1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  suvraz2
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold 
    Should Be Equal As Strings  ${resp.json()['addons']}  []

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2


YNW-TC-Upgrade License Package-2
    comment  Change Package from Trial to Gold
    Comment   Trial package have addon adword-10. total 9 adword added. when Upgradee to gold no addword will be removed
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d2}  ${sd2}  ${PUSERNAMETRIAL2}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL2}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL2}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Beautician  PhoneNo  ${ph3}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph4}  all
    ${emails1}=  Emails  Beautician  Email  ${EMPTY}  customersOnly
    ${resp}=  Create Business Profile  BBBBBB  Edathala   Devi  Edathala  ${longi1}  ${latti1}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680010  Thadathil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}    	Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  ter_stegen1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen5 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen6
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  6

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  6
    
YNW-TC-Upgrade License Package-3  
    comment  Change Package from Trial to Gold
    Comment   Trial package have addon adword-10. total 10 adword added. when Upgradee to basic no addword will be removed all will be in basic package
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d3}  ${resp.json()[2]['domain']}
    Set Test Variable  ${sd3}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d3}  ${sd3}  ${PUSERNAMETRIAL3}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL3}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL3}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph5}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph6}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  CCCCCCCC  Edathala   Devi  Edathala  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680030  Palliyil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  Aguro1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro5
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  Aguro6 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro7
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  7

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  7
    


    
YNW-TC-Upgrade License Package-4
    comment  Change Package from Trial to Gold
    Comment    Trial package have addon adword-10. total 13 adword added. when Upgrade to basic. Not remove adwords
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d6}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd6}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d6}  ${sd6}  ${PUSERNAMETRIAL4}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL4}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL4}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph7}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph8}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  DDDDDDDDD  Edathala   Devi  Edathala  ${longi3}  ${latti3}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680040  Panaparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  05s
    
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active


    ${resp}=  Add Adword  Teves1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves5
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  Teves6 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves10
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves12
    Should Be Equal As Strings  ${resp.status_code}   200
     ${resp}=  Add Adword  Teves13
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13

    comment  Upgradee License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13


YNW-TC-Upgrade License Package-5
    comment  Change Package from Trial to Gold
    Comment    Trial package have addon Upload-5 GB. total 3 adword added. nothing will remove
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d7}  ${resp.json()[6]['domain']}
    Set Test Variable  ${sd7}  ${resp.json()[6]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d7}  ${sd7}  ${PUSERNAMETRIAL5}   8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL5}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL5}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph9}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph10}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  EEEEEEEE  Edathala   An  Edathala  ${longi4}  ${latti4}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680050  Pallissery House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    

    ${resp}=  Add addon  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  latest411
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  latest522
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2
      
YNW-TC-Upgrade License Package-6
    comment  Change Package from Trial to Gold
    Comment   Trial package have addon adword-2. total 5 adword added. noting will remove
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL6}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL6}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL6}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL6}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  FFFFFFF  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  xavi
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi4
    Should Be Equal As Strings  ${resp.status_code}   200 

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5


YNW-TC-Upgrade License Package-7
    comment  Change Package from Trial to Gold
    Comment   Trial package have addon adword-50. total 53 adword added. when Upgrade to basic nothing will be removed 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL7}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL7}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL7}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  GGGGGGGG  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  sergio1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio5
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  vidal6
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messsi10
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  messi11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi12
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi13
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi14 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi15
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${resp}=  Add Adword  messi16
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi17
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi18
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi19
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi20
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${resp}=  Add Adword  messsi50
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  messi51
    Should Be Equal As Strings  ${resp.status_code}   200
    

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  22

    comment  Upgrade License
    ${resp}=  Change License Package  3
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   3
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Gold
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  22

YNW-TC-Upgrade License Package-8
    comment  Change Package from Trial to Silver
    Comment  Trial package have No addon . total 3 adword added. when Upgrade to basic 3 addword remove
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL8}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL8}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL8}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL8}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${email2}  customersOnly
    ${resp}=  Create Business Profile  AAAAAA Care  Edathala   Anjali  Thrissur  ${longi}  ${latti}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680020  Puliparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons']}  []
    
    comment  add adword

    ${resp}=  Add Adword  suvraz1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  suvraz2
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver 
    Should Be Equal As Strings  ${resp.json()['addons']}  []

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  0


YNW-TC-Upgrade License Package-9
    comment  Change Package from Trial to Silver
    Comment   Trial package have addon adword-10. total 9 adword added. when Upgrade to silver no addword will be removed
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d2}  ${sd2}  ${PUSERNAMETRIAL9}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL9}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL9}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL9}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Beautician  PhoneNo  ${ph3}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph4}  all
    ${emails1}=  Emails  Beautician  Email  ${EMPTY}  customersOnly
    ${resp}=  Create Business Profile  BBBBBB  Edathala   Devi  Edathala  ${longi1}  ${latti1}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680010  Thadathil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  ter_stegen1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen4
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  4

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  4
    
YNW-TC-Upgrade License Package-10
    comment  Change Package from Trial to Silver
    Comment   Trial package have addon adword-10. total 10 adword added. when Upgrade to silver no addword will be removed all will be in basic package
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d3}  ${resp.json()[2]['domain']}
    Set Test Variable  ${sd3}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d3}  ${sd3}  ${PUSERNAMETRIAL10}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL10}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL10}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL10}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph5}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph6}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  CCCCCCCC  Edathala   Devi  Edathala  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680030  Palliyil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  Aguro1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro5
    Should Be Equal As Strings  ${resp.status_code}   200 

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5
   
YNW-TC-Upgrade License Package-11
    comment  Change Package from Trial to Silver
    Comment    Trial package have addon adword-10. total 13 adword added. when Upgrade to basic. 3 addword will remove remaining 10 adword will in account
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d6}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd6}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d6}  ${sd6}  ${PUSERNAMETRIAL11}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL11}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL11}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph7}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph8}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  DDDDDDDDD  Edathala   Devi  Edathala  ${longi3}  ${latti3}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680040  Panaparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  05s
    
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  Teves1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves5
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  Teves6 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves10
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves12
    Should Be Equal As Strings  ${resp.status_code}   200
     ${resp}=  Add Adword  Teves13
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13

    comment  Upgradee License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13

YNW-TC-Upgrade License Package-12
    comment  Change Package from Trial to Silver
    Comment    Trial package have addon Upload-5 GB. total 3 adword added. when Upgrade to basic 3 addword remove 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d7}  ${resp.json()[6]['domain']}
    Set Test Variable  ${sd7}  ${resp.json()[6]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d7}  ${sd7}  ${PUSERNAMETRIAL12}   8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL12}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL12}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL12}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph9}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph10}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  EEEEEEEE  Edathala   An  Edathala  ${longi4}  ${latti4}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680050  Pallissery House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s    

    ${resp}=  Add addon  1 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  latest411
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  latest522
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  0
      
YNW-TC-Upgrade License Package-13
    comment  Change Package from Trial to Silver
    Comment   Trial package have addon adword-2. total 5 adword added. when Upgrade to silver 3 adword removed  
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL13}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL13}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL13}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL13}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  FFFFFFF  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  xavi
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi4
    Should Be Equal As Strings  ${resp.status_code}   200 

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5

YNW-TC-Upgrade License Package-14
    comment  Change Package from Trial to Silver
    Comment   Trial package have addon adword-50. total 20 adword added. when Upgrade to basic nothing will be removed 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL14}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL14}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL14}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL14}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  GGGGGGGG  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  sergio1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio5
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  vidal6
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messsi10
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  messi11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi12
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi13
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi14 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi15
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${resp}=  Add Adword  messi16
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi17
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi18
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi19
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi20
    Should Be Equal As Strings  ${resp.status_code}   200          

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  20

    comment  Upgrade License
    ${resp}=  Change License Package  2
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   2
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Silver
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  20

YNW-TC-Upgrade License Package-15
    comment  Change Package from Trial to Basic
    Comment  Trial package have No addon. total 3 adword added. when Upgrade to basic 3 addword remove
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL15}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL15}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL15}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL15}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${email2}  customersOnly
    ${resp}=  Create Business Profile  AAAAAA Care  Edathala   Anjali  Thrissur  ${longi}  ${latti}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680020  Puliparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons']}  []
    
    comment  add adword
    ${resp}=  Add Adword  suvraz1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  suvraz2
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic 
    Should Be Equal As Strings  ${resp.json()['addons']}  []

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  0


YNW-TC-Upgrade License Package-16
    comment  Change Package from Trial to Basic
    Comment   Trial package have addon adword-10. total 9 adword added. when Upgradee to basic no addword will be removed
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d2}  ${sd2}  ${PUSERNAMETRIAL16}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL16}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL16}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL16}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Beautician  PhoneNo  ${ph3}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph4}  all
    ${emails1}=  Emails  Beautician  Email  ${EMPTY}  customersOnly
    ${resp}=  Create Business Profile  BBBBBB  Edathala   Devi  Edathala  ${longi1}  ${latti1}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680010  Thadathil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep  03s
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  ter_stegen1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen5 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen6
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  ter_stegen9
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  9

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  9
    
YNW-TC-Upgrade License Package-17
    comment  Change Package from Trial to Basic 
    Comment   Trial package have addon adword-10. total 10 adword added. when Upgradee to basic no addword will be removed all will be in basic package
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d3}  ${resp.json()[2]['domain']}
    Set Test Variable  ${sd3}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d3}  ${sd3}  ${PUSERNAMETRIAL17}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL17}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL17}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL17}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph5}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph6}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  CCCCCCCC  Edathala   Devi  Edathala  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680030  Palliyil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  Aguro1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro5
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  Aguro6 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Aguro10
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  10

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  10

YNW-TC-Upgrade License Package-18
    comment  Change Package from Trial to Basic
    Comment    Trial package have addon adword-10. total 13 adword added. when Upgrade to basic. 3 addword will remove remaining 10 adword will in account
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d6}  ${resp.json()[5]['domain']}
    Set Test Variable  ${sd6}  ${resp.json()[5]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  arun  nv  ${None}  ${d6}  ${sd6}  ${PUSERNAMETRIAL18}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL18}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL18}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL18}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph7}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph8}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  DDDDDDDDD  Edathala   Devi  Edathala  ${longi3}  ${latti3}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680040  Panaparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  05s
    
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  Teves1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves5
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  Teves6 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves10
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  Teves12
    Should Be Equal As Strings  ${resp.status_code}   200
     ${resp}=  Add Adword  Teves13
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13

    comment  Upgradee License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  13

YNW-TC-Upgrade License Package-19
    comment  Change Package from Trial to Basic
    Comment    Trial package have addon Upload-5 GB. total 3 adword added. when Upgrade to basic 3 addword remove 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d7}  ${resp.json()[6]['domain']}
    Set Test Variable  ${sd7}  ${resp.json()[6]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  subair  nv  ${None}  ${d7}  ${sd7}  ${PUSERNAMETRIAL19}   8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL19}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL19}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL19}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Manager  PhoneNo  ${ph9}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph10}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  EEEEEEEE  Edathala   An  Edathala  ${longi4}  ${latti4}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680050  Pallissery House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Add addon  1 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  latest411
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  latest522
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Upload-50MB
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  0
      
YNW-TC-Upgrade License Package-20
    comment  Change Package from Trial to Basic
    Comment   Trial package have addon adword-2. total 5 adword added. when Upgrade to basic 3 adword removed  
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL20}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL20}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL20}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL20}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  FFFFFFF  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  4
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  xavi
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  xavi4
    Should Be Equal As Strings  ${resp.status_code}   200 

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   4
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5


YNW-TC-Upgrade License Package-21
    comment  Change Package from Trial to Basic
    Comment   Trial package have addon adword-50. total 20 adword added. when Upgrade to basic nothing will be removed 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${PUSERNAMETRIAL21}    8
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAMETRIAL21}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAMETRIAL21}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAMETRIAL21}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph_nos1}=  Phone Numbers  Doctor  PhoneNo  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  PhoneNo  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly    
    ${resp}=  Create Business Profile with location only  GGGGGGGG  MANATHAVADY   Haritha  Thrissur  ${longi5}  ${latti5}  www.sampleurl.com  free  True  680020  Puliparambil House  
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s
    ${resp}=  Add addon  5
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   8
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}   Platinum_30Day_Trial
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=  Add Adword  sergio1
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio2
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio3
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio4
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  sergio5
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  vidal6
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi7
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi8
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi9
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messsi10
    Should Be Equal As Strings  ${resp.status_code}   200 
    ${resp}=  Add Adword  messi11
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi12
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi13
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi14 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi15
    Should Be Equal As Strings  ${resp.status_code}   200  
    ${resp}=  Add Adword  messi16
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi17
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi18
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi19
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  messi20
    Should Be Equal As Strings  ${resp.status_code}   200          

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  20

    comment  Upgrade License
    ${resp}=  Change License Package  1
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Active License
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}   1
    Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  Basic
    Should Be Equal As Strings  ${resp.json()['addons'][0]['licPkgOrAddonId']}   5
    Should Be Equal As Strings  ${resp.json()['addons'][0]['name']}   Jaldee Keywords-20
    Should Be Equal As Strings  ${resp.json()['addons'][0]['status']}  Active

    ${resp}=   Get Adword   
    Should Be Equal As Strings  ${resp.status_code}   200
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  20
    
 

