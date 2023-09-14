# 2023-011-solidjs-coffee

Försöker få klippbordet att fungera på iOS.
Det verkar krävas att ett textfält är synligt.
Dock, Full Screen verkar inte tillåta textfält...

Workaround:

Chat GPT föreslår en curl-lösning mwed POST, vilket fungerade.
Bad då om en javascriptlösning och fick en node-lösning baserad på fetch.
Bad om en browserlösning och fick en javascriptlösning.
Bad om en coffeescriptlösning och fick det.
Fanns en liten bug: .text() istf .json()

Denna lösning är helt överlägsen jmf med klippbordet.


