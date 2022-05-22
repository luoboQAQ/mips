.data
    array: .space 10
.text
init:
addi    $s1,$0,4
addi    $t0,$0,0
sw      $s1,array($t0)
addi    $s1,$0,5
addi    $t0,$t0,4
sw      $s1,array($t0)
addi    $s1,$0,3
addi    $t0,$t0,4
sw      $s1,array($t0)
addi    $s1,$0,2
addi    $t0,$t0,4
sw      $s1,array($t0)
addi    $s1,$0,1
addi    $t0,$t0,4
sw      $s1,array($t0)

initfor1:
#s2 i
addi    $s2,$0,0
#t8 always 1
addi    $t8,$0,1
#t8 always 4
addi    $t9,$0,4
#s5 (len_array-1)*4
addi    $s5,$0,16

startfor1:
beq     $s2,$s5,end
initfor2:
#s3 j
addi    $s3,$0,0
#s6 (len_array-1)*4-i
addi    $s6,$0,16
subu    $s6,$s6,$s2
startfor2:
beq     $s3,$s6,endfor1
#t1 array[i]
lw      $t1,array($s3)
#s4 j+1(same as 4)
addi    $s4,$s3,4
#t2 array[j]
lw      $t2,array($s4)

if:
#t3 if t1>t2
slt     $t3,$t2,$t1
beq     $t3,$0,endfor2
swap:
sw      $t1,array($s4)
sw      $t2,array($s3)

endfor2:
addi    $s3,$s3,4
j       startfor2
endfor1:
addi    $s2,$s2,4
j       startfor1

end:
nop