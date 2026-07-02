function c --description "Run then cleanup single C file"
    gcc $argv
    ./a.out
    rm ./a.out
end

function cpp --description "Run then cleanup single C file"
    clang++ $argv
    ./a.out
    rm ./a.out
end
