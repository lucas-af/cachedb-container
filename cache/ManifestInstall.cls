Class manifest.cls.ManifestInstall Extends %RegisteredObject
{

XData Manifest [ XMLNamespace = INSTALLER ]
{
<Manifest>

    <Log Level="1" Text="PLATFORM: ${PLATFORM}" />
    <Log Level="1" Text="INSTALLDIR: ${INSTALLDIR}" />
        
    <Default Name="SystemMode" Value="DEVELOPMENT" />
        
    <Log Level="1" Text="Manifest: Configure startup ..." />
    <SystemSetting Name="Config.Startup.WebServer" Value="0"/>
    <SystemSetting Name="Config.Startup.ErrorPurge" Value="1"/>
    
    <Log Level="1" Text="Manifest: Configure Journal ..." />
    <SystemSetting Name="Config.Journal.FileSizeLimit" Value="100"/>
    <SystemSetting Name="Config.Journal.DaysBeforePurge" Value="1"/>
    <SystemSetting Name="Config.Journal.BackupsBeforePurge" Value="0"/>
    
    <Log Level="1" Text="Manifest: Enable LongStrings ..." />
    <SystemSetting Name="Config.Miscellaneous.EnableLongStrings" Value="1"/>

    <Log Level="1" Text="Manifest: Set system configuration ..." /> 
    <Invoke Class="manifest.cls.ManifestInstall" Method="setSystemSecurity" CheckStatus="true"/>
    
    <Log Level="1" Text="Manifest: Set default services configuration ..." />
    <Invoke Class="manifest.cls.ManifestInstall" Method="setDefaultServices" CheckStatus="true" />
    
    <Log Level="1" Text="Manifest: Set system mode ..." /> 
    <Invoke Class="manifest.cls.ManifestInstall" Method="setSystemMode" CheckStatus="true">
       <Arg Value="${SystemMode}"/>
    </Invoke>

    <Log Level="1" Text="Manifest: Grant role to User ..."/>
    <Invoke Class="manifest.cls.ManifestInstall" Method="grantRoleToUser" CheckStatus="true"/>
    
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
    return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Manifest")
}

ClassMethod setSystemSecurity() As %Status
{
    #dim properties As %String = ""
    #dim status As %Status = 1
    #dim error As %Exception.AbstractException = ""

    new $NAMESPACE
    set $NAMESPACE = "%SYS"
    
    try {
    
        set Properties("AutheEnabled") = 1136
        $$$ThrowOnError(##class(Security.System).Modify(,.Properties))
    
    } catch error {
        set status = error.AsStatus()
    }
    
    return status
}

ClassMethod setSystemMode(mode As %String) As %Status
{
    new $NAMESPACE
    set $NAMESPACE = "%SYS"

    set ^["%SYS"]%SYS("SystemMode") = mode
    return $$$OK
}

ClassMethod setDefaultServices() As %Status
{
    #dim properties As %String = ""
    #dim status As %Status = 1
    #dim error As %Exception.AbstractException = ""

    new $NAMESPACE
    set $NAMESPACE = "%SYS"
    
    try {
        
        kill properties
        set properties("Enabled") = 1
        set properties("AutheEnabled") = 48
    
        $$$ThrowOnError(##class(Security.Services).Modify("%Service_Terminal",.properties))
        
    } catch error {
        set status = error.AsStatus()
    }
    
    return status
}

ClassMethod grantRoleToUser() As %Status
{
    #dim result As %SQL.StatementResult = ""
    #dim status As %Status = 1
    #dim error As %Exception.AbstractException = ""   

    new $NAMESPACE
    set $NAMESPACE = "%SYS"   

    try {

        set result = ##class(%SQL.Statement).%ExecDirect(,"GRANT %All TO CSPSystem")
        if (result.%SQLCODE '= 0) {
            throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE, result.%Message)
        }

    } catch error {
        set status = error.AsStatus()
    }

    return status
}


}
