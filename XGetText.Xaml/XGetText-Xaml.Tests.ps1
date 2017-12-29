﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "XGetText-Xaml" {
    Set-Content -Path TestDrive:\TestFile.xaml -Value '<Window x:Class="NGettext.Wpf.Example.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:wpf="clr-namespace:NGettext.Wpf;assembly=NGettext.Wpf"
        mc:Ignorable="d"
        Title="{wpf:Gettext NGettext.WPF Example}" Height="350" Width="525">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
            <StackPanel.Resources>
                <Style TargetType="Button">
                    <Setter Property="Margin" Value="4,0" />
                    <Setter Property="Width" Value="80" />
                </Style>
            </StackPanel.Resources>
            <Button CommandParameter="en-US" Command="{StaticResource ChangeCultureCommand}"
                    Content="{wpf:Gettext English}" />
            <Button CommandParameter="de-DE" Command="{StaticResource ChangeCultureCommand}"
                    Content="{wpf:Gettext German}" />
            <Button CommandParameter="da-DK" Command="{StaticResource ChangeCultureCommand}"
                    Content="{wpf:Gettext Danish}" 
                    ToolTip="{wpf:Gettext Danish}" />
        </StackPanel>
    </Grid>
</Window>'

    It "Extracts msgids from given XAML file" {
        XGetText-Xaml TestDrive:\TestFile.xaml -k Gettext -o - | Should -Match ([regex]::Escape("msgid ""NGettext.WPF Example"""+ [System.Environment]::NewLine +"msgstr """"" + [System.Environment]::NewLine + [System.Environment]::NewLine)) 
    }

    It "Annotates msgid with filename and line number" {
        XGetText-Xaml TestDrive:\TestFile.xaml -k Gettext -o - | Should -Match ([regex]::Escape("#: TestFile.xaml:8" + [System.Environment]::NewLine + "msgid ""NGettext.WPF Example""")) 
    }

    It "Joins matching msgids" {
        XGetText-Xaml TestDrive:\TestFile.xaml -k Gettext -o - | Should -Match ([regex]::Escape("#: TestFile.xaml:26" + [System.Environment]::NewLine + "#: TestFile.xaml:27" + [System.Environment]::NewLine +"msgid ""Danish"""))
    }

    It "Writes output to specified file" {
        XGetText-Xaml TestDrive:\TestFile.xaml -k Gettext -o TestDrive:\Output.pot
        Get-Content TestDrive:\Output.pot | Write-Host
        'TestDrive:\Output.pot' | Should -FileContentMatchMultiline '#, fuzzy\nmsgid ""\nmsgstr ""'
    }
    
}
