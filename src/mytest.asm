alutest:
addi $t1,$0,1
addi $t2,$0,2
add  $t3,$t1,$t2
addu $t4,$t1,$t2
sub  $t3,$t2,$t1
subu $t4,$t2,$t1
and  $t3,$t1,$t2
or   $t3,$t1,$t2
nor  $t3,$t1,$t2
xor  $t3,$t1,$t2
slt  $t3,$t1,$t2
sltu $t3,$t2,$t1
sll  $t3,$t1,2
srl  $t3,$t1,2
addi $t4,$0,-10
sra  $t3,$t4,2
srav $t3,$t4,$t1
sllv $t3,$t1,$t2
srlv $t3,$t2,$t1
addiu $t3,$0,-10
andi $t3,$t1,10
ori  $t3,$t1,10
lui  $t3,10
xori $t3,$t1,10
slti $t3,$t2,3
sltiu $t3,$t2,1
branchtest:
addi $t1,$0,1
addi $t2,$0,2
beq  $t1,$t2,branchtest
addi $t2,$0,1
bne  $t1,$t2,branchtest
beq  $t1,$t2,b1
a1:
addi $t2,$0,2
bne  $t1,$t2,b2
a2:
jal jumptest
addi $t2,$0,0x3800
jr   $t2

b1:
j a1
b2:
j a2

jumptest:
jr $31