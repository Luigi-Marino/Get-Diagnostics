# **PowerShell GitHub App Template**

A minimal starting point for building PowerShell apps that run **directly from GitHub** with **no downloads**, **no installation**, and **fully in‑memory module loading**.  
This template standardises how future apps are structured, loaded, and executed, making it easy to spin up new tools with a consistent pattern.

## **Features**
- Runs entirely from a GitHub Raw URL using `iex`
- Loads modules dynamically into memory with `New-Module`
- Supports local development via automatic module import
- Lightweight, predictable structure for rapid app creation

## **Usage**
Run the app directly from GitHub:

```
iex (iwr "https://raw.githubusercontent.com/<user>/<repo>/main/app.ps1")
```

Clone locally for development:

```
.\app.ps1
```

## **Structure**
```
/modules
    template_module.psm1
app.ps1
```

