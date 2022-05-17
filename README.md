
### Run the script directly
```
nix run . Reimu Marisa
```
Or
```
nix run github:3waffel/nix-latex-demo Sakuya Reisen
```

### Notes
+ 定义输出 `eachSystem` `allSystems` 在所有系统下运行

+ 阶段 `phases`  
    + `unpack` 获得源码  
    + `build`  
    + `install`将结果复制到 `$out`  

```
nix flake lock
git init 
git add flake.{nix,lock} document.tex

nix build 
readlink result
```

+ 设置文档的时间（最后修改的时间）  
`SOURCE_DATE_EPOCH=${toString self.lastModified}`

+ 选择所用的 `scheme` 的规模  
`scheme-minimal`  
`scheme-basic`  
`scheme-full`  

+ `buildInputs` 更改为 `propagatedBuildInputs`  
因为这是运行时的依赖关系，需要在生成时推导。
