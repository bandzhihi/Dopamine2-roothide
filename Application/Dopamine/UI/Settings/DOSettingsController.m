//
//  DOSettingsController.m
//  Dopamine
//
//  Created by tomt000 on 08/01/2024.
//

#import "DOSettingsController.h"
#import <objc/runtime.h>
#import "DOUIManager.h"
#import "DOPkgManagerPickerViewController.h"
#import "DOHeaderCell.h"
#import "DOEnvironmentManager.h"
#import "DOExploitManager.h"
#import "DOPSListItemsController.h"


@interface DOSettingsController ()

@end

@implementation DOSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSArray *)availableKernelExploitIdentifiers
{
    NSMutableArray *identifiers = [NSMutableArray new];
    for (DOExploit *exploit in _availableKernelExploits) {
        [identifiers addObject:exploit.identfier];
    }
    return identifiers;
}

- (NSArray *)availableKernelExploitNames
{
    NSMutableArray *names = [NSMutableArray new];
    for (DOExploit *exploit in _availableKernelExploits) {
        [names addObject:exploit.name];
    }
    return names;
}

- (NSArray *)availablePACBypassIdentifiers
{
    NSMutableArray *identifiers = [NSMutableArray new];
    for (DOExploit *exploit in _availablePACBypasses) {
        [identifiers addObject:exploit.identfier];
    }
    if (![DOEnvironmentManager sharedManager].isPACBypassRequired) {
        [identifiers addObject:@"none"];
    }
    return identifiers;
}

- (NSArray *)availablePACBypassNames
{
    NSMutableArray *names = [NSMutableArray new];
    for (DOExploit *exploit in _availablePACBypasses) {
        [names addObject:exploit.name];
    }
    if (![DOEnvironmentManager sharedManager].isPACBypassRequired) {
        [names addObject:@"None"];
    }
    return names;
}

- (NSArray *)availablePPLBypassIdentifiers
{
    NSMutableArray *identifiers = [NSMutableArray new];
    for (DOExploit *exploit in _availablePPLBypasses) {
        [identifiers addObject:exploit.identfier];
    }
    return identifiers;
}

- (NSArray *)availablePPLBypassNames
{
    NSMutableArray *names = [NSMutableArray new];
    for (DOExploit *exploit in _availablePPLBypasses) {
        [names addObject:exploit.name];
    }
    return names;
}

- (id)specifiers
{
    if(_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray new];
        DOEnvironmentManager *envManager = [DOEnvironmentManager sharedManager];
        DOExploitManager *exploitManager = [DOExploitManager sharedManager];
        
        SEL defGetter = @selector(readPreferenceValue:);
        SEL defSetter = @selector(setPreferenceValue:specifier:);
        
        _availableKernelExploits = [exploitManager availableExploitsForType:EXPLOIT_TYPE_KERNEL].allObjects;
        if (envManager.isArm64e) {
            _availablePACBypasses = [exploitManager availableExploitsForType:EXPLOIT_TYPE_PAC].allObjects;
            _availablePPLBypasses = [exploitManager availableExploitsForType:EXPLOIT_TYPE_PPL].allObjects;
        }
        
        PSSpecifier *headerSpecifier = [PSSpecifier emptyGroupSpecifier];
        [headerSpecifier setProperty:@"DOHeaderCell" forKey:@"headerCellClass"];
        [headerSpecifier setProperty:[NSString stringWithFormat:@"Settings"] forKey:@"title"];
        [specifiers addObject:headerSpecifier];
        
        if (1 || !envManager.isJailbroken) {
            PSSpecifier *exploitGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
            exploitGroupSpecifier.name = @"Exploits";
            [specifiers addObject:exploitGroupSpecifier];
        
            PSSpecifier *kernelExploitSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Kernel Exploit" target:self set:defSetter get:defGetter detail:nil cell:PSLinkListCell edit:nil];
            kernelExploitSpecifier.detailControllerClass = [DOPSListItemsController class];
            [kernelExploitSpecifier setProperty:@"availableKernelExploitIdentifiers" forKey:@"valuesDataSource"];
            [kernelExploitSpecifier setProperty:@"availableKernelExploitNames" forKey:@"titlesDataSource"];
            [kernelExploitSpecifier setProperty:@YES forKey:@"enabled"];
            [specifiers addObject:kernelExploitSpecifier];
            
            if (envManager.isArm64e) {
                PSSpecifier *pacBypassSpecifier = [PSSpecifier preferenceSpecifierNamed:@"PAC Bypass" target:self set:defSetter get:defGetter detail:nil cell:PSLinkListCell edit:nil];
                [pacBypassSpecifier setProperty:@YES forKey:@"enabled"];
                pacBypassSpecifier.detailControllerClass = [DOPSListItemsController class];
                [pacBypassSpecifier setProperty:@"availablePACBypassIdentifiers" forKey:@"valuesDataSource"];
                [pacBypassSpecifier setProperty:@"availablePACBypassNames" forKey:@"titlesDataSource"];
                [specifiers addObject:pacBypassSpecifier];
                
                PSSpecifier *pplBypassSpecifier = [PSSpecifier preferenceSpecifierNamed:@"PPL Bypass" target:self set:defSetter get:defGetter detail:nil cell:PSLinkListCell edit:nil];
                [pplBypassSpecifier setProperty:@YES forKey:@"enabled"];
                pplBypassSpecifier.detailControllerClass = [DOPSListItemsController class];
                [pplBypassSpecifier setProperty:@"availablePPLBypassIdentifiers" forKey:@"valuesDataSource"];
                [pplBypassSpecifier setProperty:@"availablePPLBypassNames" forKey:@"titlesDataSource"];
                [specifiers addObject:pplBypassSpecifier];
            }
        }
        
        PSSpecifier *settingsGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
        settingsGroupSpecifier.name = @"Jailbreak Settings";
        [specifiers addObject:settingsGroupSpecifier];
        
        PSSpecifier *tweakInjectionSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Tweak Injection" target:self set:defSetter get:defGetter detail:nil cell:PSSwitchCell edit:nil];
        [tweakInjectionSpecifier setProperty:@YES forKey:@"enabled"];
        [tweakInjectionSpecifier setProperty:@"tweakInjectionEnabled" forKey:@"key"];
        [tweakInjectionSpecifier setProperty:@YES forKey:@"default"];
        [specifiers addObject:tweakInjectionSpecifier];
        
        if (!envManager.isJailbroken) {
            PSSpecifier *verboseLogSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Verbose Logs" target:self set:defSetter get:defGetter detail:nil cell:PSSwitchCell edit:nil];
            [verboseLogSpecifier setProperty:@YES forKey:@"enabled"];
            [verboseLogSpecifier setProperty:@"verboseLogsEnabled" forKey:@"key"];
            [verboseLogSpecifier setProperty:@NO forKey:@"default"];
            [specifiers addObject:verboseLogSpecifier];
        }
        
        PSSpecifier *idownloadSpecifier = [PSSpecifier preferenceSpecifierNamed:@"iDownload (Developer Shell)" target:self set:defSetter get:defGetter detail:nil cell:PSSwitchCell edit:nil];
        [idownloadSpecifier setProperty:@YES forKey:@"enabled"];
        [idownloadSpecifier setProperty:@"idownloaddEnabled" forKey:@"key"];
        [idownloadSpecifier setProperty:@NO forKey:@"default"];
        [specifiers addObject:idownloadSpecifier];
        
        if (!envManager.isJailbroken && !envManager.isInstalledThroughTrollStore) {
            PSSpecifier *removeJailbreakSwitchSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Remove Jailbreak" target:self set:defSetter get:defGetter detail:nil cell:PSSwitchCell edit:nil];
            [removeJailbreakSwitchSpecifier setProperty:@YES forKey:@"enabled"];
            [removeJailbreakSwitchSpecifier setProperty:@"removeJailbreakEnabled" forKey:@"key"];
            [specifiers addObject:removeJailbreakSwitchSpecifier];
        }
        
        if (envManager.isJailbroken || envManager.isInstalledThroughTrollStore) {
            PSSpecifier *actionsGroupSpecifier = [PSSpecifier emptyGroupSpecifier];
            actionsGroupSpecifier.name = @"Actions";
            [specifiers addObject:actionsGroupSpecifier];
            
            if (envManager.isJailbroken) {
                PSSpecifier *reinstallPackageManagersSpecifier = [PSSpecifier emptyGroupSpecifier];
                [reinstallPackageManagersSpecifier setProperty:@"Reinstall Package Managers" forKey:@"title"];
                [reinstallPackageManagersSpecifier setProperty:@"DOButtonCell" forKey:@"headerCellClass"];
                [reinstallPackageManagersSpecifier setProperty:@"shippingbox.and.arrow.backward" forKey:@"image"];
                [specifiers addObject:reinstallPackageManagersSpecifier];
                
                PSSpecifier *refreshAppsSpecifier = [PSSpecifier emptyGroupSpecifier];
                [refreshAppsSpecifier setProperty:@"Refresh Jailbreak Apps" forKey:@"title"];
                [refreshAppsSpecifier setProperty:@"DOButtonCell" forKey:@"headerCellClass"];
                [refreshAppsSpecifier setProperty:@"arrow.triangle.2.circlepath" forKey:@"image"];
                [specifiers addObject:refreshAppsSpecifier];
            }
            if (envManager.isJailbroken || envManager.isInstalledThroughTrollStore) {
                PSSpecifier *hideJailbreakSpecifier = [PSSpecifier emptyGroupSpecifier];
                [hideJailbreakSpecifier setProperty:@"Hide Jailbreak" forKey:@"title"];
                [hideJailbreakSpecifier setProperty:@"DOButtonCell" forKey:@"headerCellClass"];
                [hideJailbreakSpecifier setProperty:@"eye.slash" forKey:@"image"];
                [specifiers addObject:hideJailbreakSpecifier];
                
                PSSpecifier *removeJailbreakSpecifier = [PSSpecifier emptyGroupSpecifier];
                [removeJailbreakSpecifier setProperty:@"Remove Jailbreak" forKey:@"title"];
                [removeJailbreakSpecifier setProperty:@"DOButtonCell" forKey:@"headerCellClass"];
                [removeJailbreakSpecifier setProperty:@"trash" forKey:@"image"];
                if (envManager.isJailbroken) {
                    [removeJailbreakSpecifier setProperty:@"\"Hide Jailbreak\" temporarily removes jailbreak-related files and disables the jailbreak until you unhide it again." forKey:@"footerText"];
                }
                else {
                    [removeJailbreakSpecifier setProperty:@"\"Hide Jailbreak\" temporarily removes jailbreak-related files until the next jailbreak." forKey:@"footerText"];
                }
                [specifiers addObject:removeJailbreakSpecifier];
            }
        }

        _specifiers = specifiers;
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [[DOPreferenceManager sharedManager] setPreferenceValue:value forKey:[specifier propertyForKey:@"key"]];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    id value = [[DOPreferenceManager sharedManager] preferenceValueForKey:[specifier propertyForKey:@"key"]];
    if (!value) {
        return [specifier propertyForKey:@"default"];
    }
    return value;
}

#pragma mark - Button Actions

- (void)hideJailbreak
{
    //TODO
    NSLog(@"Hide Jailbreak");
}

- (void)removeJailbreak
{
    //TODO
    NSLog(@"Remove Jailbreak");
}

- (void)resetSettings
{
    [[DOUIManager sharedInstance] resetSettings];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)resetPkg
{
    [self.navigationController pushViewController:[[DOPkgManagerPickerViewController alloc] init] animated:YES];
}

@end
