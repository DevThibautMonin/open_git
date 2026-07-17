import "package:flutter_monaco/flutter_monaco.dart";

extension DiffSyntaxLanguageExtension on String {
  MonacoLanguage get diffSyntaxLanguage {
    final lower = toLowerCase();
    final fileName = lower.split("/").last;

    switch (fileName) {
      case ".env":
      case ".env.local":
      case ".env.development":
      case ".env.production":
        return MonacoLanguage.ini;
      case ".gitignore":
      case ".dockerignore":
      case ".npmignore":
      case ".prettierignore":
      case ".eslintignore":
        return MonacoLanguage.plaintext;
      case "dockerfile":
      case "containerfile":
        return MonacoLanguage.dockerfile;
      case "gemfile":
      case "rakefile":
        return MonacoLanguage.ruby;
      case "podfile":
      case "fastfile":
      case "appfile":
      case "matchfile":
      case "deliverfile":
        return MonacoLanguage.ruby;
      case "gradlefile":
        return MonacoLanguage.plaintext;
      case "go.mod":
      case "go.sum":
        return MonacoLanguage.go;
      case "package.json":
      case "package-lock.json":
      case "composer.json":
      case "tsconfig.json":
      case "jsconfig.json":
        return MonacoLanguage.json;
      case "pubspec.yaml":
      case "pubspec.yml":
      case "docker-compose.yaml":
      case "docker-compose.yml":
        return MonacoLanguage.yaml;
    }

    if (!lower.contains(".")) return MonacoLanguage.plaintext;

    final ext = fileName.split(".").last;

    return switch (ext) {
      "abap" => MonacoLanguage.abap,
      "apex" => MonacoLanguage.apex,
      "astro" => MonacoLanguage.html,
      "azcli" => MonacoLanguage.azcli,
      "bat" || "cmd" => MonacoLanguage.bat,
      "bicep" => MonacoLanguage.bicep,
      "c" => MonacoLanguage.c,
      "cc" ||
      "cpp" ||
      "cxx" ||
      "c++" ||
      "hh" ||
      "hpp" ||
      "hxx" => MonacoLanguage.cpp,
      "clj" || "cljs" || "cljc" || "edn" => MonacoLanguage.clojure,
      "coffee" || "cson" => MonacoLanguage.coffeescript,
      "cs" || "csx" => MonacoLanguage.csharp,
      "css" => MonacoLanguage.css,
      "dart" => MonacoLanguage.dart,
      "dockerfile" => MonacoLanguage.dockerfile,
      "env" => MonacoLanguage.ini,
      "ex" || "exs" => MonacoLanguage.elixir,
      "fs" || "fsx" || "fsi" => MonacoLanguage.fsharp,
      "go" => MonacoLanguage.go,
      "gql" || "graphql" => MonacoLanguage.graphql,
      "handlebars" || "hbs" => MonacoLanguage.handlebars,
      "h" => MonacoLanguage.c,
      "hcl" || "tf" || "tfvars" => MonacoLanguage.hcl,
      "html" || "htm" => MonacoLanguage.html,
      "ini" ||
      "conf" ||
      "cfg" ||
      "editorconfig" ||
      "properties" => MonacoLanguage.ini,
      "svg" || "xml" => MonacoLanguage.xml,
      "java" => MonacoLanguage.java,
      "jl" => MonacoLanguage.julia,
      "js" || "jsx" => MonacoLanguage.javascript,
      "json" => MonacoLanguage.json,
      "jsonc" => MonacoLanguage.json,
      "kt" || "kts" => MonacoLanguage.kotlin,
      "less" => MonacoLanguage.less,
      "liquid" => MonacoLanguage.liquid,
      "lua" => MonacoLanguage.lua,
      "m" || "mm" => MonacoLanguage.objectiveC,
      "md" || "markdown" => MonacoLanguage.markdown,
      "mdx" => MonacoLanguage.mdx,
      "mysql" => MonacoLanguage.mysql,
      "pas" || "p" || "pp" => MonacoLanguage.pascal,
      "perl" || "pl" || "pm" => MonacoLanguage.perl,
      "pgsql" => MonacoLanguage.pgsql,
      "php" || "phtml" => MonacoLanguage.php,
      "proto" => MonacoLanguage.proto,
      "ps1" || "psm1" || "psd1" => MonacoLanguage.powershell,
      "pug" => MonacoLanguage.pug,
      "py" || "pyw" => MonacoLanguage.python,
      "r" || "rmd" => MonacoLanguage.r,
      "razor" || "cshtml" => MonacoLanguage.razor,
      "redis" => MonacoLanguage.redis,
      "rst" => MonacoLanguage.restructuredtext,
      "rb" || "erb" => MonacoLanguage.ruby,
      "rs" => MonacoLanguage.rust,
      "scala" || "sc" => MonacoLanguage.scala,
      "scss" || "sass" => MonacoLanguage.scss,
      "sh" || "bash" || "zsh" || "fish" => MonacoLanguage.shell,
      "sol" => MonacoLanguage.sol,
      "sparql" => MonacoLanguage.sparql,
      "sql" => MonacoLanguage.sql,
      "svelte" => MonacoLanguage.html,
      "swift" => MonacoLanguage.swift,
      "sv" || "svh" => MonacoLanguage.systemverilog,
      "tcl" => MonacoLanguage.tcl,
      "toml" => MonacoLanguage.ini,
      "ts" || "tsx" => MonacoLanguage.typescript,
      "twig" => MonacoLanguage.twig,
      "vb" => MonacoLanguage.vb,
      "verilog" || "v" || "vh" => MonacoLanguage.verilog,
      "vue" => MonacoLanguage.html,
      "wgsl" => MonacoLanguage.wgsl,
      "yaml" || "yml" => MonacoLanguage.yaml,
      _ => MonacoLanguage.plaintext,
    };
  }
}
