using TSne #tSNE
using MultivariateStats #PCA

data_path = ARGS[1] # ARGS[1] must be a directory

usernames = [];
validFiles = [];

function getUsername(filename)
    m = match(r"^(.*)\.txt$", filename)
    (s,) = size(m.captures)
    if s < 1
        return ""
    else
        return String(m.captures[1])
    end
end

function tsne_reduce(dataPoints)
    Y = tsne(dataPoints, 2, 0, 1000, 15.0)

    return Y
end

# n^2
function closestPoints(X::Array{Float64, 2}, i, numPoints)

    n = size(X, 1)

    distances=[]
    for j in 1:n
        if i !== j
            push!(distances, norm(dataPoints[j, :] - dataPoints[i, :]))
        end
    end

    return X[sortperm(distances)[1:numPoints], :], distances, sortperm(distances)
end

function cluster(dataPoints)
    n = size(dataPoints, 1)

    MINPTS = 2
    RADIUS = sqrt(n * 1 / 5)

    y = zeros(n)

    currentClusterNum = 1

    for i in 1:n
        if y[i] != 0
            continue
        end

        distances=[]
        for j in 1:n
            if i !== j
                push!(distances, norm(dataPoints[j, :] - dataPoints[i, :]))
            end
        end

        if sort(distances)[MINPTS] <= RADIUS
            println("calling expandcluster on point", i)
            expandCluster!(y, dataPoints, i, currentClusterNum, RADIUS)
            currentClusterNum += 1
        end
    end

    return y
end

function expandCluster!(y, dataPoints, idx, currentClusterNum, radius)
    queue = [idx]

    n = size(dataPoints, 1)

    for o in queue
        (sortedPoints, distances, perm) = closestPoints(dataPoints, idx, n-1)

        for j in 1:n-1
            if distances[j] <= radius && y[perm[j]] == 0
                y[perm[j]] = currentClusterNum
                push!(queue, perm[j])
            end
        end
    end
end

for (_, _, fs) in walkdir(data_path)
    usernames = filter(u -> u != "", map(getUsername, fs))
    validFiles = map(u -> joinpath(data_path, "$(u).txt"), usernames);
end

followed = Dict()

mutable struct FollowedAccount
    numFollowing::Int
    following::Array{String}
end

for (n, file) in enumerate(validFiles)
    strm = open(file, "r")
    followedAccs = readlines(strm)
    for acc in followedAccs
        if haskey(followed, acc)
            followed[acc].numFollowing += 1
            push!(followed[acc].following, usernames[n])
        else
            followed[acc] = FollowedAccount(1, [usernames[n]])
        end
    end
    close(strm)
end

THRESHOLD = 15

followingToCheck = []

for (accname, accdata) in followed
    if accdata.numFollowing >= THRESHOLD
        push!(followingToCheck, accname)
    end
end

t_noneinthr = []
for username in usernames
    inAcc = map(acc -> in(username, followed[acc].following), followingToCheck)
    if !any(inAcc)
        push!(t_noneinthr, username)
    end
end

usernamesFiltered = filter(name -> !in(name, t_noneinthr), usernames)

(dim,) = size(followingToCheck)

(n,) = size(usernamesFiltered)
dataPoints = zeros(n,dim)

for (usernameIdx, username) in enumerate(usernamesFiltered)

    for (followedIdx, followedAcc) in enumerate(followingToCheck)
        if in(username, followed[followedAcc].following)
            dataPoints[usernameIdx, followedIdx] = 1
        end
    end
end

# println(dataPoints[1])
# println(size(dataPoints))
# println(dim)

function rescale(A, dim::Integer=1)
    res = A .- mean(A, dim)
    res ./= map!(x -> x > 0.0 ? x : 1.0, std(A, dim))
    res
end

reshapedData = convert(Matrix{Float64}, dataPoints)
X = rescale(reshapedData, 1)
M = fit(PCA, X'; maxoutdim = 50)

y = cluster(transform(M, X')')
@show(y)

@show(usernamesFiltered[find(y.==2)])

# using Gadfly
# p = plot(x=reduced[:,1], y=reduced[:,2])
# draw(PDF("output.pdf", 6inch, 4inch), p)
